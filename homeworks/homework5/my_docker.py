import os
import sys
import tarfile
import argparse
import subprocess

CPU_USAGE_TIME = 100000
CGROUPS_MY_DOCKER = '/sys/fs/cgroup/my_docker/'
ROOTFS_DIR = '/tmp/rootfs'


def _parse_memory_size(size_str: str) -> int:
    size_digit = int(size_str[:-1])
    unit_part = size_str[-1]
    match unit_part:
        case 'B':
            return size_digit  # bytes
        case 'K':
            return size_digit * 1024  # kbytes
        case 'M':
            return size_digit * 1024 ** 2  # mbytes
        case 'G':
            return size_digit * 1024 ** 3  # gbytes
        case _:
            raise ValueError(f"Unsupported mem unit: {unit_part}; Set as example: 100M")

def _download_and_export_docker_image(image_name, output_path):
    try:
        subprocess.run(['docker', 'pull', image_name], check=True)
        container_id = subprocess.check_output(['docker', 'create', image_name]).strip().decode('utf-8')
        subprocess.run(['docker', 'export', container_id, '--output', output_path], check=True)
        subprocess.run(['docker', 'rm', container_id], check=True)
    except subprocess.CalledProcessError as e:
        print(
            f"Error while download or export Docker image: {e}; "
            f"Try run python script as super user"
        )
        sys.exit(1)

def _extract_rootfs(tar_path, extract_path):
    if not os.path.exists(extract_path):
        os.makedirs(extract_path)
    with tarfile.open(tar_path, 'r') as tar:
        tar.extractall(path=extract_path)

def _setup_cgroups(pid, mem_limit, cpu_limit):
    if not os.path.exists(CGROUPS_MY_DOCKER):
        os.makedirs(CGROUPS_MY_DOCKER)

    if mem_limit:
        with open(os.path.join(CGROUPS_MY_DOCKER, 'memory.max'), 'w') as f:
            mem_as_bytes = _parse_memory_size(mem_limit)
            f.write(str(mem_as_bytes))

    if cpu_limit:
        with open(os.path.join(CGROUPS_MY_DOCKER, 'cpu.max'), 'w') as f:
            f.write(f"{int(float(cpu_limit) * CPU_USAGE_TIME)} {CPU_USAGE_TIME}")

    with open(os.path.join(CGROUPS_MY_DOCKER, 'cgroup.procs'), 'w') as f:
        f.write(str(pid))

def _create_namespaces():
    try:
        subprocess.run(['unshare', '--mount', '--pid', 'true'], check=True)
    except Exception as exp:
        print(f"Err while creating namespace: {exp}")

def _run_command_inside_container(related_pid, rootfs_dir, command):
    print(related_pid)
    os.chroot(rootfs_dir)
    os.chdir('/')
    os.execvp(command.split()[0], command.split())

def main():
    parser = argparse.ArgumentParser(description='Simple Docker-like container in Python')
    parser.add_argument('command', help='String command to run inside the container')
    parser.add_argument('--mem', required=False, help='Memory limit (e.g. 100M)')
    parser.add_argument('--cpu', required=False, help='CPU limit (e.g. 1.0 for 100%)')
    parser.add_argument('--root', required=False, help='Path to root filesystem tar')

    args = parser.parse_args()

    if not args.command:
        print("You must specify a command to run in the container.")
        sys.exit(1)

    if args.root:
        _extract_rootfs(args.root, ROOTFS_DIR)
    else:
        rootfs_tar = '/tmp/rootfs.tar'
        _download_and_export_docker_image('almalinux', rootfs_tar)
        _extract_rootfs(rootfs_tar, ROOTFS_DIR)

    pid = os.getpid()
    _setup_cgroups(pid, args.mem, args.cpu)

    _create_namespaces()

    _run_command_inside_container(pid, ROOTFS_DIR, args.command)

if __name__ == '__main__':
    main()