class Formatter:
    def format(self, string: str) -> str:
        pass


def format_string(string: str, formatter: Formatter | None = None) -> str:

    class DefaultFormatter(Formatter):
        """Format a string in title case."""

        def format(self, string: str) -> str:
            return str(string).title()

    if not formatter:
        formatter = DefaultFormatter()

    return formatter.format(string)


test_example = """
>>> hello_string = "hello world, how are you today?
>>> print(f" input: {hello_string}")
  input: hello world, how are you today?
>>> print(f"output: {format_string(hello_string)}")
output: Hello World, How Are You Today?
"""

__test__ = {
    name: case for name, case in globals().items() if name.startswith("test_")
}
