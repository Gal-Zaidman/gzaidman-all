from git.fetch_rebase import FetchRebase


class GitCommand(object):
    def __init__(self, parser):
        self.parser = None
        self.create_parser(parser)

    def create_parser(self, subparsers):
        parser_git = subparsers.add_parser(
            'git',
        )
        subparsers = parser_git.add_subparsers(
            title="git subcommands",
        )
        FetchRebase(subparsers)
        parser_git.set_defaults(func=self.execute)
        self.parser = parser_git
    
    def execute(self, args):
        print(args)