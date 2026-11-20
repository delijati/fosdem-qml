import shutil
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).parent.parent
MAKE = shutil.which("make")
IMAGE = "docker.io/clickable/amd64-ut24.04-1.x-amd64"

# Stand-ins for the host tools. The NVIDIA driver is loaded, so driver
# detection would pick clickable's nvidia mode.
STUBS = {
    "podman": """#!/bin/sh
echo "podman $*" >> "$STUB_LOG"
if [ "$1 $2" = "image exists" ]; then
    [ -n "$STUB_IMAGE_EXISTS" ]
    exit
fi
[ "$1" != pull ] || [ -z "$STUB_PULL_FAILS" ]
""",
    "uname": "#!/bin/sh\necho x86_64\n",
    "nvidia-smi": "#!/bin/sh\nexit 0\n",
    "lsmod": "#!/bin/sh\necho 'Module Size Used by'\necho 'nvidia 54001664 12'\n",
}


def make(tmp_path, target, podman=True, **env):
    """Run a make target with the stubs; clickable only echoes its arguments.

    Returns the exit code, the output lines and the podman calls.
    """
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    for name, script in STUBS.items():
        if name == "podman" and not podman:
            continue
        stub = bin_dir / name
        stub.write_text(script)
        stub.chmod(0o755)
    for tool in ("echo", "grep"):
        (bin_dir / tool).symlink_to(shutil.which(tool))
    log = tmp_path / "podman.log"
    log.touch()
    result = subprocess.run(
        [MAKE, "-s", "-C", str(ROOT), target, "CLICKABLE=echo clickable"],
        env={"PATH": str(bin_dir), "STUB_LOG": str(log), **env},
        capture_output=True,
        text=True,
    )
    return result.returncode, result.stdout.splitlines(), log.read_text().splitlines()


def test_desktop_runs_without_nvidia_mode(tmp_path):
    code, out, calls = make(tmp_path, "desktop")

    assert code == 0
    assert calls == ["podman image exists " + IMAGE, "podman pull " + IMAGE]
    assert out[-1] == "clickable desktop --no-nvidia"


def test_desktop_nvidia_mode_on_request(tmp_path):
    code, out, calls = make(tmp_path, "desktop", CLICKABLE_NVIDIA="1")

    assert code == 0
    assert calls[-1] == "podman pull " + IMAGE + "-nvidia"
    assert out[-1] == "clickable desktop --nvidia"


@pytest.mark.parametrize("target, command", [
    ("build", "clickable build"),
    ("device", "clickable"),
    ("review", "clickable review"),
])
def test_image_pulled_before_clickable(tmp_path, target, command):
    code, out, calls = make(tmp_path, target)

    assert code == 0
    assert calls == ["podman image exists " + IMAGE, "podman pull " + IMAGE]
    assert out[-1] == command


def test_existing_image_not_pulled(tmp_path):
    code, out, calls = make(tmp_path, "build", STUB_IMAGE_EXISTS="1")

    assert code == 0
    assert calls == ["podman image exists " + IMAGE]
    assert out == ["clickable build"]


def test_failed_pull_stops_before_clickable(tmp_path):
    code, out, calls = make(tmp_path, "build", STUB_PULL_FAILS="1")

    assert code != 0
    assert "clickable build" not in out


@pytest.mark.parametrize("podman, env", [
    (False, {}),
    (True, {"CLICKABLE_DOCKER_COMMAND": "docker"}),
])
def test_no_pull_with_docker(tmp_path, podman, env):
    code, out, calls = make(tmp_path, "desktop", podman=podman, **env)

    assert code == 0
    assert calls == []
    assert out == ["clickable desktop --no-nvidia"]


@pytest.mark.parametrize("args, part", [
    (["bump"], "patch"),
    (["bump", "major"], "major"),
    (["bump", "minor"], "minor"),
    (["bump", "PART=major"], "major"),
])
def test_bump_part(args, part):
    result = subprocess.run([MAKE, "-n", "--no-print-directory", "-C", str(ROOT), *args], capture_output=True, text=True)

    assert result.returncode == 0, result.stderr
    bumps = [line for line in result.stdout.splitlines() if "bump2version" in line]
    assert bumps == ["uvx bump2version --verbose " + part]


def test_bump_rejects_unknown_part():
    result = subprocess.run([MAKE, "-C", str(ROOT), "bump", "PART=huge"], capture_output=True, text=True)

    assert result.returncode != 0
    assert "major, minor or patch" in result.stderr
