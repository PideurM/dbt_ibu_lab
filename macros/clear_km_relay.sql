{% macro clear_km_relays(column_name) %}
    RIGHT({{ column_name }}, LENGTH({{ column_name }}) - POSITION('x' IN {{ column_name }})) AS {{ column_name }}
{% endmacro %}
