/*Autores:
César Alberto Bravo Pariente
Kaiala de Jesus Santos
*/

/*
@brief: O seguinte código gera, a partir de pontos de controle Bezier, a malha 3D do bico do Teapot de Newell 
        conectando quatro caminhos curvos para formar a estrutura tubular do bico e exportando o resultado em um arquivo no formato PLY.
*/

PrintWriter pontos;

/*
@brief: Vetor bidimensional contendo os pontos de controle do bico divididos entre o plano positivo (Z > 0) e negativo (Z < 0).
        Baseado no esboço de Martin Newell, com vértices mapeados manualmente por Kaiala Santos.
*/
float[][] pts = {
  {3.25, 1.2, 1.5},   //v0
  {5.7, 1.7, 1.5},    //v1
  {4.7, 4.5, 0.5},    //v2
  {6.6, 5.65, 0.5},   //v3
  {5.5, 5.65, 0.5},   //v4
  {4.75, 4.95, 0.5},  //v5
  {4.95, 3.25, 1.5},  //v6
  {3.25, 3.25, 1.5},  //v7
  
  {3.25, 1.2, -1.5},  //v8
  {5.7, 1.7, -1.5},   //v9
  {4.7, 4.5, -0.5},   //v10
  {6.6, 5.65, -0.5},  //v11
  {5.5, 5.65, -0.5},  //v12
  {4.75, 4.95, -0.5}, //v13
  {4.95, 3.25, -1.5}, //v14
  {3.25, 3.25, -1.5}, //v15
};

//Quantidade de subdivisões lineares por trecho de curva de Bézier.
int passosBezier = 10;

//Quantidade total de pontos gerados ao longo de cada curva individualizada do bico.
int pontosPorCaminho = passosBezier + 1;

/*
@brief: Configura o ambiente, calcula as coordenadas interpoladas do bico usando matrizes estáticas, 
        constrói a topologia tubular conectando as faces laterais, superiores e inferiores, gerando o arquivo PLY final.
*/
void setup() {
  pontos = createWriter("teapotBicoBezier.ply");
  size(800, 600, P3D);

  // Alocação estática dos vértices gerados: 4 curvas guias multiplicadas por pontosPorCaminho
  int totalVertices = 4 * pontosPorCaminho;
  float[][] listaVertices = new float[totalVertices][3];
  int contadorVertices = 0;

  // Alocação estática das faces quadrangulares: 4 conjuntos de laços longitudinais de faces
  int totalFaces = 4 * passosBezier;
  int[][] listaFaces = new int[totalFaces][4];
  int contadorFaces = 0;

  int[][] caminhos = {
    {0, 1, 2, 3},     //Lado 1 - Inferior
    {7, 6, 5, 4},     //Lado 1 - Superior
    {8, 9, 10, 11},   //Lado 2 - Inferior
    {15, 14, 13, 12}  //Lado 2 - Superior
  };

  int[][] gridVertices = new int[4][pontosPorCaminho];

  //Gera os vértices suavizados pelas curvas de Bézier
  for (int c = 0; c < 4; c++) {
    float[] p0 = pts[caminhos[c][0]];
    float[] p1 = pts[caminhos[c][1]];
    float[] p2 = pts[caminhos[c][2]];
    float[] p3 = pts[caminhos[c][3]];

    for (int i = 0; i <= passosBezier; i++) {
      float t = i / (float)passosBezier;
      float[] psuave = calcularBezierFormula(p0, p1, p2, p3, t);
      
      listaVertices[contadorVertices] = psuave;
      gridVertices[c][i] = contadorVertices++;
    }
  }

  //RECONSTRUÇÃO DAS FACES
  
  // Faces do Lado 1
  for (int i = 0; i < passosBezier; i++) {
    listaFaces[contadorFaces][0] = gridVertices[0][i];
    listaFaces[contadorFaces][1] = gridVertices[0][i+1];
    listaFaces[contadorFaces][2] = gridVertices[1][i+1];
    listaFaces[contadorFaces][3] = gridVertices[1][i];
    contadorFaces++;
  }

  // Faces do Lado 2
  for (int i = 0; i < passosBezier; i++) {
    listaFaces[contadorFaces][0] = gridVertices[3][i];
    listaFaces[contadorFaces][1] = gridVertices[3][i+1];
    listaFaces[contadorFaces][2] = gridVertices[2][i+1];
    listaFaces[contadorFaces][3] = gridVertices[2][i];
    contadorFaces++;
  }

  // Faces de Ligação Superior (Une o Lado 2 ao Lado 1 por cima)
  for (int i = 0; i < passosBezier; i++) {
    listaFaces[contadorFaces][0] = gridVertices[3][i];
    listaFaces[contadorFaces][1] = gridVertices[1][i];
    listaFaces[contadorFaces][2] = gridVertices[1][i+1];
    listaFaces[contadorFaces][3] = gridVertices[3][i+1];
    contadorFaces++;
  }

  // Faces de Ligação Inferior (Une o Lado 2 ao Lado 1 por baixo)
  for (int i = 0; i < passosBezier; i++) {
    listaFaces[contadorFaces][0] = gridVertices[2][i];
    listaFaces[contadorFaces][1] = gridVertices[2][i+1];
    listaFaces[contadorFaces][2] = gridVertices[0][i+1];
    listaFaces[contadorFaces][3] = gridVertices[0][i];
    contadorFaces++;
  }

  pontos.println("ply");
  pontos.println("format ascii 1.0");
  pontos.println("element vertex " + totalVertices);
  pontos.println("property float x");
  pontos.println("property float y");
  pontos.println("property float z");
  pontos.println("element face " + totalFaces);
  pontos.println("property list uchar int vertex_index");
  pontos.println("end_header");

  for (int i = 0; i < totalVertices; i++) {
    pontos.println(listaVertices[i][0] + "\t" + listaVertices[i][1] + "\t" + listaVertices[i][2]);
  }

  for (int i = 0; i < totalFaces; i++) {
    pontos.println("4 " + listaFaces[i][0] + " " + listaFaces[i][1] + " " + listaFaces[i][2] + " " + listaFaces[i][3]);
  }

  pontos.flush();
  pontos.close();
  exit();
}

/*
@brief: Calcula as coordenadas de um ponto em uma curva de Bézier Cúbica aplicando diretamente a fórmula polinomial expandida por extenso, sem depender de funções internas ou bibliotecas do Processing.
@param: p0 - Vetor float[3] com a coordenada do ponto inicial (âncora).
@param: p1 - Vetor float[3] com a coordenada do primeiro ponto de controle (manípulo).
@param: p2 - Vetor float[3] com a coordenada do segundo ponto de controle (manípulo).
@param: p3 - Vetor float[3] com a coordenada do ponto final (âncora).
@param: t - Valor float de 0.0 a 1.0 que indica o parâmetro de interpolação ao longo da curva.
@return: float[3] correspondente às coordenadas calculadas no instante t.
*/
float[] calcularBezierFormula(float[] p0, float[] p1, float[] p2, float[] p3, float t) {
  float[] resultado = new float[3];
  
  float u = 1.0 - t;
  
  resultado[0] = (u * u * u) * p0[0] + 3 * (u * u) * t * p1[0] + 3 * u * (t * t) * p2[0] + (t * t * t) * p3[0];
  resultado[1] = (u * u * u) * p0[1] + 3 * (u * u) * t * p1[1] + 3 * u * (t * t) * p2[1] + (t * t * t) * p3[1];
  resultado[2] = (u * u * u) * p0[2] + 3 * (u * u) * t * p1[2] + 3 * u * (t * t) * p2[2] + (t * t * t) * p3[2];
  
  return resultado;
}
