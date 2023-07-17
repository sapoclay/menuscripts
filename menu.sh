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
    titulo=$(tput setaf 2)   # Color verde
    rojo=$(tput setaf 1)     # Color rojo
    normal=$(tput sgr0)      # Restaurar color por defecto
    negrita=$(tput bold)     # Texto en negrita

    echo "${titulo}----- MENÚ -----${normal}"
    echo "${negrita}${rojo}1. ${normal}Cargar script"
    echo "${negrita}${rojo}2. ${normal}Editar script"
    echo "${negrita}${rojo}3. ${normal}Ejecutar script"
    echo "${negrita}${rojo}4. ${normal}Ver lista de scripts"
    echo "${negrita}${rojo}5. ${normal}Eliminar script"
    echo "${negrita}${rojo}6. ${normal}Editar rutas de un script"
    echo "${negrita}${rojo}7. ${normal}Ver lista de categorías"
    echo "${negrita}${rojo}8. ${normal}Agregar categoría"
    echo "${negrita}${rojo}9. ${normal}Asignar categoría a script"
    echo "${negrita}${rojo}10. ${normal}Buscar por nombre o categoría"
    echo "${negrita}${rojo}11. ${normal}Salir"
    echo "-----------------"
}

# Función para cargar un script y darle permisos de ejecución
function cargar_script() {
    read -p "Ingrese la ruta del script a cargar: " ruta_script
    if [ -f "$ruta_script" ]; then
        if [ -x "$ruta_script" ]; then
            echo "$ruta_script ya tiene permisos de ejecución."
        else
            chmod +x "$ruta_script"
            echo "Permisos de ejecución asignados a $ruta_script."
        fi
        echo "$ruta_script" >> "$ruta_archivo"
        echo "Script cargado y con permisos de ejecución."
    else
        echo "El archivo no existe o no es un script válido."
    fi
}

# Función para editar un script
function editar_script() {
    echo "----- Lista de Scripts Cargados -----"
    cat -n "$ruta_archivo"
    echo "-------------------------------------"
    read -p "Ingrese el número del script a editar: " num_script
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
    read -p "Ingrese el número del script a ejecutar: " num_script
    ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
    if [ -f "$ruta_script" ]; then
        read -p "Ingrese los parámetros para el script (si es necesario): " parametros
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
        read -p "Ingrese el número del script a eliminar: " num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            rm "$ruta_script"
            sed -i "${num_script}d" "$ruta_archivo"
            sed -i "/^$ruta_script:/d" "$ruta_categorias"
            echo "Script eliminado y ruta removida del archivo."
        else
            echo "El archivo no existe o no es un script válido."
        fi
    else
        echo "La lista está vacía. Cargue algunos scripts primero."
    fi
}
# Función para editar rutas
function editar_rutas() {
    if [ -s "$ruta_archivo" ]; then
        echo "----- Lista de Scripts Cargados -----"
        cat -n "$ruta_archivo"
        echo "-------------------------------------"
        read -p "Ingrese el número del script cuya ruta desea editar: " num_script
        ruta_script_antigua=$(sed -n "${num_script}p" "$ruta_archivo")
        
        read -p "Ingrese la nueva ruta para el script: " ruta_script_nueva
        if [ -f "$ruta_script_antigua" ]; then
            mv "$ruta_script_antigua" "$ruta_script_nueva"
            sed -i "${num_script}s|$ruta_script_antigua|$ruta_script_nueva|" "$ruta_archivo"
            echo "Ruta actualizada exitosamente."
        else
            echo "El archivo no existe o no es un script válido."
        fi
    else
        echo "La lista está vacía. Cargue algunos scripts primero."
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
    read -p "Ingrese el nombre de la categoría: " categoria
    echo "$categoria" >> "$ruta_categorias"
    echo "Categoría agregada exitosamente."
}

function asignar_categoria_a_script() {
    if [ -s "$ruta_archivo" ]; then
        echo "----- Lista de Scripts Cargados -----"
        cat -n "$ruta_archivo"
        echo "-------------------------------------"
        read -p "Ingrese el número del script al que desea asignar una categoría: " num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            echo "----- Lista de Categorías -----"
            cat -n "$ruta_categorias"
            echo "--------------------------------"
            read -p "Ingrese el número de la categoría que desea asignar al script: " num_categoria
            categoria=$(sed -n "${num_categoria}p" "$ruta_categorias")
            echo "$ruta_script:$categoria" >> "$ruta_categorias"
            echo "Categoría asignada exitosamente al script."
        else
            echo "El archivo no existe o no es un script válido."
        fi
    else
        echo "La lista está vacía. Cargue algunos scripts primero."
    fi
}

# Función para buscar por nombre o categoría
function buscar_scripts() {
    read -p "Ingrese el nombre o categoría a buscar: " busqueda
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
    read -p "Ingrese una opción: " opcion

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
        11) echo "¡Hasta luego!"; break;;
        *) echo "Opción inválida, intente nuevamente.";;
    esac

    echo "Presione Enter para continuar..."
    read -s
done
