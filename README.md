<div align="center">

# asdf-aws-nuke ![Build](https://github.com/bersalazar/asdf-aws-nuke/workflows/Build/badge.svg) ![Lint](https://github.com/bersalazar/asdf-aws-nuke/workflows/Lint/badge.svg)

[aws-nuke](https://github.com/rebuy-de/aws-nuke) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add aws-nuke
# or
asdf plugin add https://github.com/bersalazar/asdf-aws-nuke.git
```

aws-nuke:

```shell
# Show all installable versions
asdf list-all aws-nuke

# Install specific version
asdf install aws-nuke latest

# Set a version globally (on your ~/.tool-versions file)
asdf global aws-nuke latest

# Now aws-nuke commands are available
aws-nuke version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/bersalazar/asdf-aws-nuke/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Bernardo Salazar](https://github.com/bersalazar/)
