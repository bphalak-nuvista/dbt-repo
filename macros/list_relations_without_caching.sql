{% macro spark__list_relations_without_caching(schema_relation) %}

    {# ---------------------------------------------------------
       Get all objects exposed by SparkSessionCatalog.
       SHOW TABLES returns:
           namespace
           tableName
           isTemporary
       --------------------------------------------------------- #}

    {% call statement('list_tables', fetch_result=True) -%}
        SHOW TABLES IN {{ schema_relation.schema }}
    {%- endcall %}


    {# ---------------------------------------------------------
       Get views separately because SHOW TABLES does not provide
       reliable relation-type information.
       --------------------------------------------------------- #}

    {% call statement('list_views', fetch_result=True) -%}
        SHOW VIEWS IN {{ schema_relation.schema }}
    {%- endcall %}


    {% set tables_result = load_result('list_tables').table %}
    {% set views_result = load_result('list_views').table %}


    {# ---------------------------------------------------------
       Build a list containing the names of views.
       --------------------------------------------------------- #}

    {% set view_names = [] %}

    {% for row in views_result.rows %}
        {% do view_names.append(row['viewName']) %}
    {% endfor %}


    {# ---------------------------------------------------------
       SQLAdapter.list_relations_without_caching() expects each
       result row to contain exactly 4 values:

           database
           identifier
           schema
           type

       It will subsequently call Relation.create() itself.
       --------------------------------------------------------- #}

    {% set relations = [] %}

    {% for row in tables_result.rows %}

        {% set identifier = row['tableName'] %}

        {% if not row['isTemporary'] %}

            {% if identifier in view_names %}
                {% set relation_type = 'view' %}
            {% else %}
                {% set relation_type = 'table' %}
            {% endif %}

            {% do relations.append([
                schema_relation.database,
                identifier,
                schema_relation.schema,
                relation_type
            ]) %}

        {% endif %}

    {% endfor %}


    {{ return(relations) }}

{% endmacro %}
