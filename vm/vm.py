from vm.create import CreateVmFromIso


class NfsCommand(object):
    def __init__(self, parser):
        self.parser = None
        self.create_parser(parser)

    def create_parser(self, subparsers):
        parser = subparsers.add_parser(
            'vm',
        )
        subparsers = parser.add_subparsers(
            title="vm subcommands",
        )
        CreateVmFromIso(subparsers)
        parser.set_defaults(func=self.execute)
        self.parser = parser
    
    def execute(self, args):
        print(args)