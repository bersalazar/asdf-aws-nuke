# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test aws-nuke https://github.com/bersalazar/asdf-aws-nuke.git "aws-nuke version"
```

Tests are automatically run in GitHub Actions on push and PR.
