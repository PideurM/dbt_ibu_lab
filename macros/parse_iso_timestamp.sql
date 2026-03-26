{% macro parse_iso_timestamp(column_name) %}
    TRY_TO_TIMESTAMP_NTZ({{ column_name }}, 'YYYY-MM-DD"T"HH24:MI:SSZ')
{% endmacro %}
