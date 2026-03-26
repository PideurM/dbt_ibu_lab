{% macro convert_time_to_seconds(column_name) %}
    {% if column_name %}
        SPLIT_PART({{ column_name }}, ':', 1)::FLOAT * 60
        + SPLIT_PART({{ column_name }}, ':', 2)::FLOAT
    {% else %}
        NULL
    {% endif %}
{% endmacro %}
