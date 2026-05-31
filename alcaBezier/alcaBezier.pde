/*Autores:
César Alberto Bravo Pariente
Kaiala de Jesus Santos
*/

/*
@brief: O seguinte código gera, a partir de pontos de controle Bezier, a malha 3D tridimensional da alça do Teapot de Newell 
        conectando quatro caminhos curvos para formar uma estrutura tubular e exportando o resultado em um arquivo no formato PLY.
*/

PrintWriter pontos;

/*
@brief: Vetor bidimensional contendo os pontos de controle da alça divididos entre o plano positivo (Z = 0.5) e negativo (Z = -0.5).
        Baseado no esboço de Martin Newell, com vértices mapeados manualmente por Kaiala Santos.
*/
float[][] pts = {
  {-2.75, 5.3, 0.5}, //v0
  {-4.7, 5.3, 0.5}, //v1
  {-5.7, 5.3, 0.5}, //v2
  {-5.7, 4.2, 0.5}, //v3
  {-5.7, 3.1, 0.5}, //v4
  {-5.0, 2.0, 0.5}, //v5
  {-3.2, 1.1, 0.5}, //v6
  {-3.4, 1.9, 0.5}, //v7
  {-4.7, 2.5, 0.5}, //v8
  {-5.1, 3.6, 0.5}, //v9
  {-5.1, 4.2, 0.5}, //v10
  {-5.1, 4.7, 0.5}, //v11
  {-4.3, 4.7, 0.5}, //v12
  {-2.85, 4.7, 0.5}, //v13
  
  {-2.75, 5.3, -0.5}, //v14
  {-4.7, 5.3, -0.5}, //v15
  {-5.7, 5.3, -0.5}, //v16
  {-5.7, 4.2, -0.5}, //v17
  {-5.7, 3.1, -0.5}, //v18
  {-5.05, 2.05, -0.5}, //v19
  {-3.2, 1.1, -0.5}, //v20
  {-3.4, 1.9, -0.5}, //v21
  {-4.7, 2.5, -0.5}, //v22
  {-5.1, 3.6, -0.5}, //v23
  {-5.1, 4.2, -0.5}, //v24
  {-5.1, 4.7, -0.5}, //v25
  {-4.3, 4.7, -0.5}, //v26
  {-2.85, 4.7, -0.5} //v27
};

//Quantidade de subdivisões lineares por trecho de curva de Bézier.
int passosBezier = 10;

//Quantidade total de pontos gerados ao longo de cada perfil completo da alça.
int pontosPorCaminho = (2 * passosBezier) + 1;

/*
@brief: Configura o ambiente, calcula as coordenadas interpoladas dos caminhos da alça usando matrizes estáticas lineares, 
        constrói a topologia conectando as faces quadrangulares das extremidades e gera o arquivo PLY.
*/
void setup() {
  pontos = createWriter("tepotalcaBezier.ply");
  size(800, 600, P3D);

  // Alocação estática dos vértices gerados: 4 perfis guias multiplicados por pontosPorCaminho
  int totalVertices = 4 * pontosPorCaminho;
  float[][] listaVertices = new float[totalVertices][3];
  int contadorVertices = 0;

  // Alocação estática das faces: 4 conjuntos laterais de quadriláteros + 2 tampas de fechamento das pontas
  int totalFaces = (4 * (pontosPorCaminho - 1)) + 2;
  int[][] listaFaces = new int[totalFaces][4];
  int contadorFaces = 0;

  int[][] caminhos = {
    {0, 1, 2, 3, 4, 5, 6}, // Lado 1 - Externo
    {13, 12, 11, 10, 9, 8, 7}, // Lado 1 - Interno (invertido para alinhar direção com o externo)
    {14, 15, 16, 17, 18, 19, 20}, // Lado 2 - Externo
    {27, 26, 25, 24, 23, 22, 21} // Lado 2 - Interno (invertido)
  };

  int[][] gridVertices = new int[4][pontosPorCaminho];

  for (int c = 0; c < 4; c++) {
    int idxCaminho = 0;
    
    // Curva 1: v0 -> v3
    for (int i = 0; i < passosBezier; i++) {
      float t = i / (float)passosBezier;
      float[] psuave = calcularBezierFormula(pts[caminhos[c][0]], pts[caminhos[c][1]], pts[caminhos[c][2]], pts[caminhos[c][3]], t);
      listaVertices[contadorVertices] = psuave;
      gridVertices[c][idxCaminho++] = contadorVertices++;
    }
    
    //Curva 2: v3 -> v6
    for (int i = 0; i <= passosBezier; i++) {
      float t = i / (float)passosBezier;
      float[] psuave = calcularBezierFormula(pts[caminhos[c][3]], pts[caminhos[c][4]], pts[caminhos[c][5]], pts[caminhos[c][6]], t);
      listaVertices[contadorVertices] = psuave;
      gridVertices[c][idxCaminho++] = contadorVertices++;
    }
  }

  //RECONSTRUÇÃO DAS FACES
  
  // lado 1
  for (int i = 0; i < pontosPorCaminho - 1; i++) {
    listaFaces[contadorFaces][0] = gridVertices[0][i];
    listaFaces[contadorFaces][1] = gridVertices[0][i+1];
    listaFaces[contadorFaces][2] = gridVertices[1][i+1];
    listaFaces[contadorFaces][3] = gridVertices[1][i];
    contadorFaces++;
  }

  // lado 2
  for (int i = 0; i < pontosPorCaminho - 1; i++) {
    listaFaces[contadorFaces][0] = gridVertices[3][i];
    listaFaces[contadorFaces][1] = gridVertices[3][i+1];
    listaFaces[contadorFaces][2] = gridVertices[2][i+1];
    listaFaces[contadorFaces][3] = gridVertices[2][i];
    contadorFaces++;
  }

  // superior
  for (int i = 0; i < pontosPorCaminho - 1; i++) {
    listaFaces[contadorFaces][0] = gridVertices[2][i];
    listaFaces[contadorFaces][1] = gridVertices[2][i+1];
    listaFaces[contadorFaces][2] = gridVertices[0][i+1];
    listaFaces[contadorFaces][3] = gridVertices[0][i];
    contadorFaces++;
  }
  
  // inferior
  for (int i = 0; i < pontosPorCaminho - 1; i++) {
    listaFaces[contadorFaces][0] = gridVertices[1][i];
    listaFaces[contadorFaces][1] = gridVertices[1][i+1];
    listaFaces[contadorFaces][2] = gridVertices[3][i+1];
    listaFaces[contadorFaces][3] = gridVertices[3][i];
    contadorFaces++;
  }
  
  // Fechamentos das extremidades que conectam ao corpo do bule
  listaFaces[contadorFaces][0] = gridVertices[0][0];
  listaFaces[contadorFaces][1] = gridVertices[1][0];
  listaFaces[contadorFaces][2] = gridVertices[3][0];
  listaFaces[contadorFaces][3] = gridVertices[2][0];
  contadorFaces++;

  listaFaces[contadorFaces][0] = gridVertices[0][pontosPorCaminho - 1];
  listaFaces[contadorFaces][1] = gridVertices[1][pontosPorCaminho - 1];
  listaFaces[contadorFaces][2] = gridVertices[3][pontosPorCaminho - 1];
  listaFaces[contadorFaces][3] = gridVertices[2][pontosPorCaminho - 1];
  contadorFaces++;

  pontos.println("ply");
  pontos.println("format ascii 1.0");
  pontos.println("element vertex " + totalVertices);
  pontos.println("property float x");
  pontos.println("property float y");
  pontos.println("property float z");
  pontos.println("element face " + totalFaces);
  pontos.println("property list uchar int vertex_index");
  pontos.println("end_header");

  // Impressão sequencial das coordenadas calculadas
  for (int i = 0; i < totalVertices; i++) {
    pontos.println(listaVertices[i][0] + "\t" + listaVertices[i][1] + "\t" + listaVertices[i][2]);
  }

  //Impressão sequencial das malhas poligonais indexadas
  for (int i = 0; i < totalFaces; i++) {
    //Inversão de sentido da última face para manter consistência das normais da malha
    if (i == totalFaces - 1) {
      pontos.println("4 " + listaFaces[i][0] + " " + listaFaces[i][2] + " " + listaFaces[i][3] + " " + listaFaces[i][1]);
    } else {
      pontos.println("4 " + listaFaces[i][0] + " " + listaFaces[i][1] + " " + listaFaces[i][2] + " " + listaFaces[i][3]);
    }
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
