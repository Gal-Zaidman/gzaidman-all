#!/bin/python3

import argparse
from git.git import GitCommand
from common.log import createLog
from nfs.nfs import

def createArgParser():
    # Create the main command
    parser = argparse.ArgumentParser(
        prog="gzaidman",
        description="Helper tool to automate tasks that I do on a daily bases",
        allow_abbrev=False
    )
    parser.add_argument(
        "-l",
        "--log-level",
        required=False,
        default='DEBUG'
    )
    # Define the list of subparsers, each correspond to a command
    subparsers = parser.add_subparsers(
        title="gzaidman tools subcommands",
        description="Commands this tool implements"
    )
    GitCommand(subparsers)
    return parser

def main():
    parser = createArgParser()
    args = parser.parse_args()
    createLog(args.log_level)
    try:
        args.func(args)
    except AttributeError as e:
        # TODO: Add invalid choies message like running git dd
        print("Called with no args, exeption")
    

if __name__ == "__main__":
    main()