import logging

from common.log import debug_decor
from common.command import execute

class CreateVmFromIso(object):
    def __init__(self, parser):
        self.parser = None
        self.create_parser(parser)

    def create_parser(self, subparsers):
        parser_fetch_rebase = subparsers.add_parser("fetch-rebase")
        parser_fetch_rebase.add_argument(
            "-r", "--remote", required=False, default="origin"
        )
        parser_fetch_rebase.add_argument(
            "-rb", "--remote-branch", required=False, default="master"
        )
        parser_fetch_rebase.add_argument(
            "-lb", "--local-branch", required=False, default="master"
        )
        parser_fetch_rebase.set_defaults(func=self.execute)
        self.parser = parser_fetch_rebase

    @debug_decor
    def execute(self, args):
        execute(f"sudo virt-install --name {args.name} --memory {args.mem} --vcpus {args.cpus} --network network={args.network},mac={args.mac} --cdrom={args.iso_path} --disk size={args.disk_size}")
