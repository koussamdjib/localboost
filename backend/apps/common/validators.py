"""Common validation utilities for serializers."""
from rest_framework import serializers


def validate_choice_field(value, choices, field_name=""):
    """Validate that value is in allowed choices."""
    valid_values = {choice[0] for choice in choices}
    if value not in valid_values:
        msg = f"Invalid {field_name}." if field_name else "Invalid choice."
        raise serializers.ValidationError(msg)
    return value


def validate_date_range(start_field, end_field, data):
    """Validate that start <= end for date range fields."""
    start = data.get(start_field)
    end = data.get(end_field)
    
    if start and end and start > end:
        raise serializers.ValidationError(
            {end_field: f"{end_field} must be after {start_field}."}
        )
    return data
