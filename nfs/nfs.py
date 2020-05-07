from git.fetch_rebase import FetchRebase


class NfsCommand(object):
    def __init__(self, parser):
        self.parser = None
        self.create_parser(parser)

    def create_parser(self, subparsers):
        parser_nfs = subparsers.add_parser(
            'nfs',
        )
        subparsers = parser_nfs.add_subparsers(
            title="nfs subcommands",
        )
        FetchRebase(subparsers)
        parser_nfs.set_defaults(func=self.execute)
        self.parser = parser_nfs
    
    def execute(self, args):
        print(args)