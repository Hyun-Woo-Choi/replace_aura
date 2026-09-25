"""Export a trained calibration model to Core ML for on-device inference.

Usage: python export_coreml.py --model path/to/model.joblib --out ../WatchWelliOS/Models/StressCalibration.mlpackage
"""

from __future__ import annotations

import argparse


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", required=True, help="Trained scikit-learn model (joblib)")
    parser.add_argument("--out", required=True, help="Output .mlpackage path")
    args = parser.parse_args()

    import coremltools as ct  # imported lazily: heavy dependency
    import joblib

    model = joblib.load(args.model)
    # TODO: name the input features to match BanditContext / StressCalculator on iOS.
    mlmodel = ct.converters.sklearn.convert(model)
    mlmodel.save(args.out)


if __name__ == "__main__":
    main()
