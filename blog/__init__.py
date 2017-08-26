from typing import Tuple

from flask import jsonify

OK = jsonify
Created = Tuple[jsonify, int]


def handle_validation_error(error) -> OK:
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response
