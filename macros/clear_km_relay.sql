{# TODO: Create a macro that extracts the km value from relay format (e.g., '4x6' → '6')
   Hint: Use RIGHT(), LENGTH(), and POSITION('x' IN ...) to extract the part after 'x'
   Don't forget to add an AS alias! #}

{% macro clear_km_relays(column_name) %}
    {{ column_name }}
{% endmacro %}
