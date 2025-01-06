# Proyecto de Reconocimiento de Filas y Columnas por Voz e Imagen

Este proyecto utiliza técnicas de reconocimiento de patrones para determinar las coordenadas (fila y columna) a partir de entrada por voz o imagen. Está implementado en MATLAB y combina el uso de **Modelos Ocultos de Markov (HMM)** y técnicas de procesamiento de imágenes.

## Contenido

- [Características](#características)
- [Requisitos](#requisitos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Lectura y Procesamiento de una Cuadrícula](#lectura-y-procesamiento-de-una-cuadrícula)
- [Configuración](#configuración)
- [Uso](#uso)
- [Colaboradores](#colaboradores)

## Características

- Reconocimiento de voz para obtener las coordenadas utilizando Modelos Ocultos de Markov (HMM).
- Reconocimiento de patrones visuales para identificar las coordenadas en imágenes.
- Interfaz interactiva para seleccionar el método deseado.
- Configurable para distintos números de centroides y estados en el HMM.

## Requisitos

- MATLAB R2020b o superior.
- Toolboxes necesarios:
  - Signal Processing Toolbox
  - Image Processing Toolbox
- Archivos de modelos y codebooks previamente entrenados.

# Estructura del Proyecto
## Lectura y Procesamiento de una Cuadrícula 
Esta parte tiene como objetivo capturar una imagen en tiempo real desde una cámara, procesarla para detectar y extraer una cuadrícula, y realizar un análisis sobre la misma. Las funciones desarrolladas abarcan desde la adquisición de imágenes hasta la corrección de su orientación y su binarización:

### 1. **leerCuadricula**
Esta función principal se encarga de capturar video en tiempo real desde la cámara y permite procesar la imagen cuando se presiona una tecla. El flujo de trabajo incluye:

 1. Captura de imágenes en tiempo real.
 2. Preprocesamiento de la imagen mediante la función `preprocesado`.
 3. Extracción de la cuadrícula con la función `imprimirMatriz`.
 4. Devuelve una matriz con los números de la cuadrícula y su tamaño.

### 2. **preprocesado**
Se encarga de transformar la imagen capturada en una versión binaria optimizada para análisis detectar los números posteriormente. Sus pasos incluyen:

 1. Conversión a escala de grises.
 2. Ajuste de los niveles de intensidad.
 3. Generación de una imagen binaria basada en un umbral.
 4. Aplicación de máscaras mediante la función `aplicarMascara`.
 5. Enderezamiento de la imagen mediante la función `enderezarImagen`.
 6. Detección y extracción de la región más grande de interés(que debe ser la cuadrícula).

### 3. **aplicarMascara**
Esta función "rellena" las regiones en blanco dentro de una máscara de tamaño definido como argumento de la función. Su lógica incluye:

 1. Detectar regiones donde todos los valores dentro de la máscara son `1` y establecerlos a `0`.
 2. Asegurar que los bordes de la imagen se ajusten a negro.

### 4. **enderezarImagen**
Corrige la orientación de la imagen identificando las líneas verticales mediante:

 1. Aplicación del operador de Canny para detectar bordes.
 2. Uso de la Transformada de Hough para identificar líneas rectas.
 3. Selección de la línea vertical más larga y cálculo del ángulo respecto al eje vertical para rotar la imagen.

### 5. **imprimirMatriz**
Identifica y organiza los números presentes en una cuadrícula NxN.
 1. Detecta las regiones conectadas en la imagen binaria.
 2. Filtra las regiones según su área.
 3. Compara las regiones con las plantillas de números almacenadas en la carpeta `NUMEROS`.
 4. Asocia los números a las regiones y organiza los resultados en una matriz mediante la función `rellenarMatriz`.
 5. Devuelve la matriz con los valores correspondientes a la cuadrícula.
