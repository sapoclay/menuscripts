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
    amarillo=$(tput setaf 3)   # Color amarillo
    azul=$(tput setaf 4)     # Color azul
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
    read -p "${negrita}${amarillo}Escribe la ruta del script a cargar: ${normal}" ruta_script
    if [ -f "$ruta_script" ]; then
        if [ -x "$ruta_script" ]; then
            echo "$ruta_script ya tiene permisos de ejecución."
        else
            chmod +x "$ruta_script"
            echo "${titulo}Permisos de ejecución asignados a $ruta_script.${normal}"
        fi
        echo "$ruta_script" >> "$ruta_archivo"
        echo "${titulo}Script cargado con éxito${normal}"
    else
        echo "${negrita}${rojo}El archivo no existe o no es un script válido.${normal}"
    fi
}

# Función para editar un script
function editar_script() {
    echo "${titulo}----- Lista de Scripts Cargados -----${normal}"
    cat -n "$ruta_archivo"
    echo "${titulo}-------------------------------------${normal}"
    read -p "${negrita}${amarillo}Escribe el número del script a editar: ${normal}" num_script
    ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
    if [ -f "$ruta_script" ]; then
        gedit "$ruta_script"
    else
        echo "${negrita}${rojo}El archivo no existe o no es un script válido.${normal}"
    fi
}

# Función para ejecutar un script
function ejecutar_script() {
    echo "${titulo}----- Lista de Scripts Cargados -----${normal}"
    cat -n "$ruta_archivo"
    echo "${titulo}-------------------------------------${normal}"
    read -p "${negrita}${amarillo}Escribe el número del script a ejecutar: ${normal}" num_script
    ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
    if [ -f "$ruta_script" ]; then
        read -p "${negrita}${amarillo}Escribe los parámetros para el script (si es necesario. De lo contrario pulsa Intro): ${normal}" parametros
        bash "$ruta_script" $parametros
    else
        echo "${negrita}${rojo}El archivo no existe o no es un script válido.${normal}"
    fi
}

# Función para ver los scripts y sus categorías
function ver_lista_scripts() {
    if [ -s "$ruta_categorias" ]; then
        echo "${titulo}----- Lista de Scripts Cargados y sus Categorías -----${normal}"
        categorias_sin_scripts=()

        while IFS=':' read -r script categoria; do
            if [ -n "$script" ]; then
                if [ -n "$categoria" ]; then
                    echo "${titulo}Categoría: $categoria ${normal} - ${titulo}Script: $script ${normal}"
                else
                    categorias_sin_scripts+=("$script")
                fi
            fi
        done < "$ruta_categorias"

        # Mostrar las categorías sin scripts asociados
       #  for categoria in "${categorias_sin_scripts[@]}"; do
       #      echo "${negrita}${rojo}Sin categoría ${normal} - ${titulo}Script: $categoria ${normal}"
       #  done

        echo "${titulo}-----------------------------------------------------${normal}"
    else
        echo "${negrita}${rojo}No hay scripts con categorías asignadas.${normal}"
    fi
}

# Función para eliminar un script y su ruta del archivo
function eliminar_script() {
    if [ -s "$ruta_archivo" ]; then
        echo "${titulo}----- Lista de Scripts Cargados -----${normal}"
        cat -n "$ruta_archivo"
        echo "${titulo}-------------------------------------${normal}"
        read -p "${negrita}${amarillo}Escribe el número del script a eliminar: ${normal}" num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            rm "$ruta_script"
            sed -i "${num_script}d" "$ruta_archivo"
            sed -i "/^$ruta_script:/d" "$ruta_categorias"
            echo "${titulo}Script y ruta eliminados correctamente.${normal}"
        else
            echo "${negrita}${rojo}El archivo no existe o no es un script válido.${normal}"
        fi
    else
        echo "${negrita}${rojo}La lista está vacía. Carga algunos scripts primero.${normal}"
    fi
}

# Función para copiar un script a otra ubicación y cambiar su nombre
function copiar_script() {
    if [ -s "$ruta_archivo" ]; then
        echo "${titulo}----- Lista de Scripts Cargados -----${normal}"
        cat -n "$ruta_archivo"
        echo "${titulo}-------------------------------------${normal}"
        read -p "${negrita}${amarillo}Escribe el número del script a copiar:${normal} " num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            read -p "${negrita}${amarillo}Escribe la ruta y el nombre nuevo para el script: ${normal}" ruta_nueva_script
            cp "$ruta_script" "$ruta_nueva_script"
            echo "$ruta_nueva_script" >> "$ruta_archivo"
            echo "${titulo}Script copiado correctamente en la ruta $ruta_nueva_script.${normal}"
        else
            echo "${negrita}${rojo}El archivo no existe o no es un script válido.${normal}"
        fi
    else
        echo "${negrita}${rojo}La lista está vacía. Carga algunos scripts primero.${normal}"
    fi
}

# Función para editar rutas
function editar_rutas() {
    if [ -s "$ruta_archivo" ]; then
        echo "${titulo}----- Lista de Scripts Cargados -----${normal}"
        cat -n "$ruta_archivo"
        echo "${titulo}-------------------------------------${normal}"
        read -p "${negrita}${amarillo}Escribe el número del script cuya ruta quieres modificar: ${normal}" num_script
        ruta_script_antigua=$(sed -n "${num_script}p" "$ruta_archivo")
        
        read -p "${negrita}${amarillo}Escribe la nueva ruta para el script: ${normal}" ruta_script_nueva
        if [ -f "$ruta_script_antigua" ]; then
            mv "$ruta_script_antigua" "$ruta_script_nueva"
            sed -i "${num_script}s|$ruta_script_antigua|$ruta_script_nueva|" "$ruta_archivo"
            echo "${titulo}Ruta actualizada correctamente en $ruta_script_nueva ${normal}"
        else
            echo "${negrita}${rojo}El archivo no existe o no es un script válido. ${normal}"
        fi
    else
        echo "${negrita}${rojo}La lista está vacía. Carga algunos scripts primero. ${normal}"
    fi
}

# Función para ver la lista de categorías y los archivos asociados
function ver_lista_categorias() {
    if [ -s "$ruta_categorias" ]; then
        echo "${titulo}----- Lista de Categorías y Scripts ----- ${normal}"
        while IFS=':' read -r script categoria; do
            echo "Categoría: $categoria"
            echo "Scripts:"
            awk -F ':' -v cat="$categoria" '$2 == cat {print $1}' "$ruta_categorias"
            echo "${titulo}---------------------------------------${normal}"
        done < "$ruta_categorias"
    else
        echo "${negrita}${rojo}No hay categorías registradas.${normal}"
    fi
}

function agregar_categoria() {
    read -p "${negrita}${amarillo}Escribe el nombre de la categoría para crearla: ${normal}" categoria
    echo "$categoria" >> "$ruta_categorias"
    echo "${titulo}Categoría añadida correctamente. ${normal}"
}

function asignar_categoria_a_script() {
    if [ -s "$ruta_archivo" ]; then
        echo "${titulo}----- Lista de Scripts Cargados -----${normal}"
        cat -n "$ruta_archivo"
        echo "${titulo}-------------------------------------${normal}"
        read -p "${negrita}${amarillo}Escribe el número del script al que quieres asignar una categoría: ${normal}" num_script
        ruta_script=$(sed -n "${num_script}p" "$ruta_archivo")
        if [ -f "$ruta_script" ]; then
            echo "${titulo}----- Lista de Categorías -----${normal}"
            cat -n "$ruta_categorias"
            echo "${titulo}--------------------------------${normal}"
            read -p "${negrita}${amarillo}Escribe el número de la categoría que quieres asignar al script: ${normal}" num_categoria
            categoria=$(sed -n "${num_categoria}p" "$ruta_categorias")
            echo "$ruta_script:$categoria" >> "$ruta_categorias"
            echo "${titulo}Categoría asignada correctamente al script.${normal}"
        else
            echo "${negrita}${rojo}El archivo no existe o no es un script válido.${normal}"
        fi
    else
        echo "${negrita}${rojo}La lista está vacía. Carga algunos scripts primero.${normal}"
    fi
}

# Función para buscar por nombre o categoría
function buscar_scripts() {
    read -p "${negrita}${amarillo}Escribe el nombre o categoría a buscar:${normal} " busqueda
    if [ -s "$ruta_categorias" ]; then
        echo "${titulo}----- Resultados de la búsqueda -----${normal}"
        grep -i "$busqueda" "$ruta_categorias" | while read -r line; do
            categoria=$(echo "$line" | cut -d':' -f2)
            script=$(echo "$line" | cut -d':' -f1)
            echo "Categoría: $categoria - Script: $script"
        done
        echo "${titulo}--------------------------------------${normal}"
    else
        echo "${negrita}${rojo}No hay scripts con categorías asignadas.${normal}"
    fi
}

# Main
while true; do
    mostrar_menu
    read -p "${negrita}${amarillo}Escribe una opción:${normal} " opcion

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
        12) echo "${titulo}PROGRAMA TERMINADO!!${normal}"; break;;
        *) echo "${negrita}${rojo}Opción inválida. Selecciona una opción del menú.${normal}";;
    esac

    echo "${negrita}${azul}Pulsa Intro para continuar...${normal}"
    read -s
done
