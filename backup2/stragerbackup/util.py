import pipes
import typing

_secret_environment_variables = set()


def command_string(
    command: typing.Sequence[str], extra_env: typing.Dict[str, str] = {}
) -> str:
    command_string = ""
    for (env_name, env_value) in extra_env.items():
        if env_name in _secret_environment_variables:
            env_value_str = "--REDACTED--"
        else:
            env_value_str = pipes.quote(env_value)
        command_string += f"{pipes.quote(env_name)}={env_value_str} "
    command_string += " ".join(map(pipes.quote, command))
    return command_string
