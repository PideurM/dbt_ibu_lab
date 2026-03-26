{% macro select_spares(column_name) %}
    LEFT({{ column_name }}, POSITION('+' IN {{ column_name }}) - 1) AS {{ column_name }},
    RIGHT({{ column_name }}, LENGTH({{ column_name }}) - POSITION('+' IN {{ column_name }})) AS {{ column_name }}_spare
{% endmacro %}
