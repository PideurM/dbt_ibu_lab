{# TODO: Create a macro that splits a 'prone+standing' shootings column into two columns
   Example: '0+1' → shootings = '0', shootings_spare = '1'
   Hint: Use LEFT(), RIGHT(), LENGTH(), and POSITION('+' IN ...)
   The macro should output TWO columns separated by a comma #}

{% macro select_spares(column_name) %}
    {{ column_name }}
{% endmacro %}
