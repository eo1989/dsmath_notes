"""
From Python Object-Oriented Programming 4|5th edition
Chapter 2-?
"""

import datetime
from collections.abc import Iterable


class Sample:
    def __init__(
        self,
        sepal_length: float,
        sepal_width: float,
        petal_length: float,
        petal_width: float,
        species: str | None = None,
    ) -> None:

        self.sepal_length = sepal_length
        self.sepal_width = sepal_width
        self.petal_length = petal_length
        self.petal_width = petal_width
        self.species = species
        self.classification: str | None = None

    def __repr__(self) -> str:
        if self.species is None:
            known_unknown = "UnknownSample"
        else:
            known_unknown = "KnownSample"

        if self.classification is None:
            classification = ""
        else:
            classification = f", classification = {self.classification!r}"

        return (
            f"{known_unknown}("
            f"sepal_length={self.sepal_length}, "
            f"sepal_width={self.sepal_width}, "
            f"petal_length={self.petal_length}, "
            f"petal_width={self.petal_width}, "
            f"species={self.species!r}"
            f"{classification}"
            f")"
        )

    # Method 1: defines the state change from unclassified to classified.
    def classify(self, classification: str) -> None:
        self.classification = classification

    # Method 2: compares the results of classification with Botanist-assigned
    # species. Used for testing.
    def matches(self) -> bool:
        return self.species == self.classification


class Hyperparameter:
    """Hyperparameter value and the overall quality of the classification."""

    def __init__(self, k: int, training: TrainingData) -> None:
        self.k = k
        self.data = TrainingData = training
        self.quality: float

    def test(self) -> None:
        """Run entire test suite."""
        pass_count, fail_count = 0, 0
        for sample in self.data.testing:
            sample.classification = self.classify(samples)
            if sample.matches():
                pass_count += 1
            else:
                fail_count += 1
        self.quality = pass_count / (pass_count + fail_count)

    def classify(self, sample: Sample) -> str:
        # TODO: the k-NN algorithm
        return ""


class TrainingData:
    def __init__(self, name: str) -> None:
        self.name = name
        self.uploaded: datetime.datetime
        self.tested: datetime.datetime
        self.training: list[Sample] = []
        self.testing: list[Sample] = []
        self.tuning: list[Hyperparameter] = []

    def load(self, raw_data_source: Iterable[dict[str, str]]) -> None:
        """Load & partition the raw datars."""

        for n, row in enumerate(raw_data_source):
            # ... filter & extract subsets (See ch.6 of Python Object-Oriented Programming S.Lott 4|5E)
            # create self.training & self.testing subsets
            # {
            #     "sepal_length": 5.1,
            #     "sepal_width": 3.5,
            #     "petal_length": 1.4,
            #     "petal_width": 0.2,
            #     "species": "Iris-setosa"
            # }
            sample = Sample(
                sepal_length=float(row["sepal_length"]),
                sepal_width=float(row["sepal_width"]),
                petal_length=float(row["petal_length"]),
                petal_width=float(row["petal_width"]),
                species=row["species"],
            )
            if n % 5 == 0:
                self.testing.append(sample)
            else:
                self.training.append(sample)

            self.uploaded = datetime.datetime.now(tz=datetime.UTC)

    def test(self, parameter: Hyperparameter) -> None:
        """Test this Hyperparameter value."""
        parameter.test()
        self.tuning.append(parameter)
        self.tested = datetime.datetime.now(tz=datetime.UTC)

    def classify(self, parameter: Hyperparameter, sample: Sample) -> Sample:
        """Classify this Sample."""
        classification = parameter.classify(sample)
        sample.classify(classification)
        return sample


test_Sample = """
>>> x = Sample(1, 2, 3, 4)
>>> x
UknownSample(septal_length = 1, septal_width = 2, petal_length = 3, petal_width = 4, species=None)
"""
