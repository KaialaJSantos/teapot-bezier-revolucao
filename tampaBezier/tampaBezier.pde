/*Autores:
César Alberto Bravo Pariente
Kaiala de Jesus Santos
*/

/*
@brief: O seguinte código gera, a partir de pontos de controle Bezier, a malha 3D da tampa do Teapot de Newell 
        rotacionando o perfil gerado e exportando o resultado em um arquivo no formato PLY.
*/

PrintWriter pontos;

/*
@brief: Vetor bidimensional contendo os pontos de controle do perfil tridimensional da tampa.
        Baseado no esboço de Martin Newell, com vértices mapeados manualmente por Kaiala Santos.
*/
float[][] pts = {
  {-2.5, 5.65, 0.0}, //v0
  {-2.5, 6.0, 0.0}, //v1
  {-0.8, 6.0, 0.0}, //v2
  {-0.4, 6.4, 0.0}, //v3
  {-0.2, 6.8, 0.0}, //v4
  {-0.6, 7.2, 0.0}, //v5
  {-1.4, 7.65, 0.0}, //v6
  {0.0, 7.65, 0.0} //v7
};

//Quantidade de divisões rotacionais ao redor do eixo de revolução para gerar a malha 3D.
int fatias = 12;

/*
@brief: Configura o ambiente do Processing, realiza o cálculo de amostragem das curvas de Bézier usando a fórmula explícita por extenso, 
        faz a revolução dos pontos em 360 graus, gera as faces quadrangulares e exporta a malha final no arquivo PLY. 
        Encerra a execução ao finalizar.
*/
void setup() {
  pontos = createWriter("teapotTampaBezier.ply");
  size(800, 600, P3D);
  background(0);

  int passosBezier = 10; // Quantidade de subdivisões por curva
  int pontosPorFatia = (2 * passosBezier) + 1; // 2 curvas conectadas geram (2 * passosBezier + 1) pontos no perfil final suavizado

  float[][] perfilSuave = new float[pontosPorFatia][3];
  int indexPerfil = 0;

  //Curva 1: v0 -> v3
  for (int i = 0; i < passosBezier; i++) {
    float t = i / (float)passosBezier;
    perfilSuave[indexPerfil] = calcularBezierFormula(pts[0], pts[1], pts[2], pts[3], t);
    indexPerfil++;
  }

  //Curva 2: v4 -> v7
  for (int i = 0; i <= passosBezier; i++) {
    float t = i / (float)passosBezier;
    perfilSuave[indexPerfil] = calcularBezierFormula(pts[4], pts[5], pts[6], pts[7], t);
    indexPerfil++;
  }

  int nVertices = pontosPorFatia * fatias;
  int nFaces = fatias * (pontosPorFatia - 1);

  pontos.println("ply");
  pontos.println("format ascii 1.0");
  pontos.println("comment generated in Processing");
  pontos.println("element vertex " + nVertices);
  pontos.println("property float x");
  pontos.println("property float y");
  pontos.println("property float z");
  pontos.println("element face " + nFaces);
  pontos.println("property list uchar int vertex_index");
  pontos.println("end_header");

  /*
  @brief: Função que gera e escreve os vértices rotacionados (sólido de revolução)
          Usando a fórmula para rotação em torno do eixo Y com deslocamento angular inicial
  */
  float theta = TWO_PI / fatias;
  float deslocamentoInicial = theta / 2.0; 
  
  for (int j = 0; j < fatias; j++) {
    float ang = deslocamentoInicial + (j * theta); 
    for (int i = 0; i < pontosPorFatia; i++) {
      float x = perfilSuave[i][0];
      float y = perfilSuave[i][1];
      float z = perfilSuave[i][2];
      // rotação em torno do eixo Y
      float u = cos(ang) * x - sin(ang) * z;
      float v = y;
      float w = sin(ang) * x + cos(ang) * z;
      pontos.println(u + "\t" + v + "\t" + w);
    }
  }

  // Função que gera e escreve os índices das faces (quadriláteros)
  for (int k = 0; k < fatias; k++) {
    int prox = (k + 1) % fatias;
    for (int l = 0; l < pontosPorFatia - 1; l++) {
      int v1 = k * pontosPorFatia + l;
      int v2 = k * pontosPorFatia + (l + 1);
      int v3 = prox * pontosPorFatia + (l + 1);
      int v4 = prox * pontosPorFatia + l;
      pontos.println("4 " + v1 + "\t" + v2 + "\t" + v3 + "\t" + v4);
    }
  }

  pontos.flush();
  pontos.close();
  exit();
}

/*
@brief: Calcula as coordenadas de um ponto em uma curva de Bézier Cúbica.
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
