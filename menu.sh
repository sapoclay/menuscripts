#!/bin/bash

# Archivo donde se guardarán las rutas de los scripts
ruta_archivo="scripts.txt"
# Archivo donde se guardarán las categorías
ruta_categorias="categorias.txt"

# Comprobamos si el archivo de categorías existe, si no, lo creamos
if [ ! -f "$ruta_categorias" ]; then
    touch "$ruta_categorias"
fi

function mostrar_menu() {
    clear
    
    # Colores y estilo para el menú
    titulo=$(tput setaf 2)   # Color verde
    rojo=$(tput setaf 1)     # Color rojo
    normal=$(tput sgr0)      # Restaurar color por defecto
    negrita=$(tput bold)     # Texto en negrita

    echo "${titulo}----- MENÚ -----${normal}"
    echo "${negrita}${rojo}1. ${normal}Cargar la ruta de un script"
    echo "${negrita}${rojo}2. ${normal}Editar un script"
    echo "${negrita}${rojo}3. ${normal}Ejecutar un script"
    echo "${negrita}${rojo}4. ${normal}Ver lista de los scripts guardados"
    echo "${negrita}${rojo}5. ${normal}Eliminar un script"
    echo "${negrita}${rojo}6. ${normal}Editar la ruta de un script"
    echo "${negrita}${rojo}7. ${normal}Ver el lista de categorías disponibles"
    echo "${negrita}${rojo}8. ${normal}Añadir una categoría"
    echo "${negrita}${rojo}9. ${normal}Asignar una categoría a un script"
    echo "${negrita}${rojo}10. ${normal}Buscar por nombre o categoría"
    echo "${negrita}${rojo}11. ${normal}Realizar una copia de seguridad de un script"
    echo "${negrita}${rojo}12. ${normal}Salir"
    echo "${titulo}-----------------${normal}"
}

# Función para cargar un script y darle permisos de ejecución
function cargar_script() {
    read -p "Escribe la ruta del script a cargar: " ruta_script
    if [ -f "$ruta_script" ]; then
        if [ -x "$ruta_script" ]; then
            echo "$ruta_script ya tiene permisos de ejecución."
        else
            chmod +x "$ruta_script"
            echo "Permisos de ejecución asignados a $ruta_script."
        fi
        echo "$ruta_script" >> "$ruta_archivo"
        echo "Script cargado con éxito"
    else
        echo "El archivo no existe o no es un script válido."
    fi
}

# Función para editar un script
function editar_script() {
    echo "----- Lista de Scripts Cargados -----"
    cat -n "$ruta_archivo"
    echo "-------------------------------------"
    read -p "Escribe el número del script a editar: " num_script
    ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
    if [ -f "$ruta_script" ]; then
        gedit "$ruta_script"
    else
        echo "El archivo no existe o no es un script válido."
    fi
}

# Función para ejecutar un script
function ejecutar_script() {
    echo "----- Lista de Scripts Cargados -----"
    cat -n "$ruta_archivo"
    echo "-------------------------------------"
    read -p "Escribe el número del script a ejecutar: " num_script
    ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
    if [ -f "$ruta_script" ]; then
        read -p "Escribe los parámetros para el script (si es necesario. De lo contrario pulsa Intro): " parametros
        bash "$ruta_script" $parametros
    else
        echo "El archivo no existe o no es un script válido."
    fi
}

# Función para ver la lista de scripts cargados y sus categorías
function ver_lista_scripts() {
    if [ -s "$ruta_categorias" ]; then
        echo "----- Lista de Scripts Cargados y sus Categorías -----"
        while IFS=':' read -r script categoria; do
            if [ -n "$script" ]; then
                if [ -n "$categoria" ]; then
                    echo "Categoría: $categoria - Script: $script"
                else
                    echo "Sin categoría - Script: $script"
                fi
            else
                if [ -n "$categoria" ]; then
                    echo "Categoría: $categoria - Sin scripts asociados"
                fi
            fi
        done < "$ruta_categorias"
        echo "-----------------------------------------------------"
    else
        echo "No hay scripts con categorías asignadas."
    fi
}

# Función para eliminar un script y su ruta del archivo
function eliminar_script() {
    if [ -s "$ruta_archivo" ]; then
        echo "----- Lista de Scripts Cargados -----"
        cat -n "$ruta_archivo"
        echo "-------------------------------------"
        read -p "Escribe el número del script a eliminar: " num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            rm "$ruta_script"
            sed -i "${num_script}d" "$ruta_archivo"
            sed -i "/^$ruta_script:/d" "$ruta_categorias"
            echo "Script eliminado y ruta eliminada del archivo."
        else
            echo "El archivo no existe o no es un script válido."
        fi
    else
        echo "La lista está vacía. Carga algunos scripts primero."
    fi
}

# Función para copiar un script a otra ubicación y cambiar su nombre
function copiar_script() {
    if [ -s "$ruta_archivo" ]; then
        echo "----- Lista de Scripts Cargados -----"
        cat -n "$ruta_archivo"
        echo "-------------------------------------"
        read -p "Escribe el número del script a copiar: " num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            read -p "Escribe la ruta y el nombre nuevo para el script: " ruta_nueva_script
            cp "$ruta_script" "$ruta_nueva_script"
            echo "$ruta_nueva_script" >> "$ruta_archivo"
            echo "Script copiado correctamente en la ruta $ruta_nueva_script."
        else
            echo "El archivo no existe o no es un script válido."
        fi
    else
        echo "La lista está vacía. Carga algunos scripts primero."
    fi
}

# Función para editar rutas
function editar_rutas() {
    if [ -s "$ruta_archivo" ]; then
        echo "----- Lista de Scripts Cargados -----"
        cat -n "$ruta_archivo"
        echo "-------------------------------------"
        read -p "Escribe el número del script cuya ruta quieres modificar: " num_script
        ruta_script_antigua=$(sed -n "${num_script}p" "$ruta_archivo")
        
        read -p "Escribe la nueva ruta para el script: " ruta_script_nueva
        if [ -f "$ruta_script_antigua" ]; then
            mv "$ruta_script_antigua" "$ruta_script_nueva"
            sed -i "${num_script}s|$ruta_script_antigua|$ruta_script_nueva|" "$ruta_archivo"
            echo "Ruta actualizada correctamente en $ruta_script_nueva"
        else
            echo "El archivo no existe o no es un script válido."
        fi
    else
        echo "La lista está vacía. Carga algunos scripts primero."
    fi
}

# Función para ver la lista de categorías y los archivos asociados
function ver_lista_categorias() {
    if [ -s "$ruta_categorias" ]; then
        echo "----- Lista de Categorías y Scripts -----"
        while IFS=':' read -r script categoria; do
            echo "Categoría: $categoria"
            echo "Scripts:"
            awk -F ':' -v cat="$categoria" '$2 == cat {print $1}' "$ruta_categorias"
            echo "---------------------------------------"
        done < "$ruta_categorias"
    else
        echo "No hay categorías registradas."
    fi
}

function agregar_categoria() {
    read -p "Escribe el nombre de la categoría para crearla: " categoria
    echo "$categoria" >> "$ruta_categorias"
    echo "Categoría añadida correctamente."
}

function asignar_categoria_a_script() {
    if [ -s "$ruta_archivo" ]; then
        echo "----- Lista de Scripts Cargados -----"
        cat -n "$ruta_archivo"
        echo "-------------------------------------"
        read -p "Escribe el número del script al que quieres asignar una categoría: " num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            echo "----- Lista de Categorías -----"
            cat -n "$ruta_categorias"
            echo "--------------------------------"
            read -p "Escribe el número de la categoría que quieres asignar al script: " num_categoria
            categoria=$(sed -n "${num_categoria}p" "$ruta_categorias")
            echo "$ruta_script:$categoria" >> "$ruta_categorias"
            echo "Categoría asignada correctamente al script."
        else
            echo "El archivo no existe o no es un script válido."
        fi
    else
        echo "La lista está vacía. Carga algunos scripts primero."
    fi
}

# Función para buscar por nombre o categoría
function buscar_scripts() {
    read -p "Escribe el nombre o categoría a buscar: " busqueda
    if [ -s "$ruta_categorias" ]; then
        echo "----- Resultados de la búsqueda -----"
        grep -i "$busqueda" "$ruta_categorias" | while read -r line; do
            categoria=$(echo "$line" | cut -d':' -f2)
            script=$(echo "$line" | cut -d':' -f1)
            echo "Categoría: $categoria - Script: $script"
        done
        echo "--------------------------------------"
    else
        echo "No hay scripts con categorías asignadas."
    fi
}

# Main
while true; do
    mostrar_menu
    read -p "Escribe una opción: " opcion

    case $opcion in
        1) cargar_script;;
        2) editar_script;;
        3) ejecutar_script;;
        4) ver_lista_scripts;;
        5) eliminar_script;;
        6) editar_rutas;;
        7) ver_lista_categorias;;
        8) agregar_categoria;;
        9) asignar_categoria_a_script;;
        10) buscar_scripts;;
        11) copiar_script;;
        12) echo "¡Hasta luego!"; break;;
        *) echo "Opción inválida. Selecciona una opción del menú.";;
    esac

    echo "Pulsa Intro para continuar..."
    read -s
done
