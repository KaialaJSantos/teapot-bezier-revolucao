/*Autores:
César Alberto Bravo Pariente
Kaiala de Jesus Santos
*/

/*
@brief: O seguinte código gera, a partir de pontos de controle Bezier, a malha 3D da borda (assento da tampa) do Teapot de Newell 
        rotacionando o perfil gerado e exportando o resultado em um arquivo no formato PLY.
*/

PrintWriter pontos;

/*
@brief: Vetor bidimensional contendo os pontos de controle do perfil tridimensional.
        Baseado no esboço de Martin Newell, com vértices mapeados manualmente por Kaiala Santos.
*/
float[][] pts = {
  {2.85, 5.7, 0.0}, //v0
  {2.7, 5.9, 0.0}, //v1
  {2.6, 5.7, 0.0} //v2
};

//Quantidade de divisões rotacionais ao redor do eixo de revolução para gerar a malha 3D.
int fatias = 8; 

//Define a quantidade de segmentos/subdivisões para suavizar a curva de Bézier.
int passosBezier = 10; 

//Quantidade total de pontos gerados no perfil final suavizado para cada fatia da malha.
int pontosPorFatia = passosBezier + 1;

/*
@brief: Configura o ambiente do Processing, mapeia os pontos para o formato cúbico, calcula a amostragem da curva 
        de Bézier por extenso, aplica a revolução com deslocamento inicial, gera as faces quadrangulares e exporta a malha no arquivo PLY.
*/
void setup() {
  pontos = createWriter("teapotBordaBezier.ply");
  size(800, 600, P3D);

  float[][] perfilSuave = new float[pontosPorFatia][3];
  
  // Mapeia os 3 pontos originais para os 4 pontos necessários para a curva cúbica
  float[] p0 = pts[0];
  float[] p1 = pts[1];
  float[] p2 = pts[1]; //Duplicado
  float[] p3 = pts[2];

  for (int i = 0; i <= passosBezier; i++) {
    float t = i / (float)passosBezier;
    perfilSuave[i] = calcularBezierFormula(p0, p1, p2, p3, t);
  }

  int nVertices = pontosPorFatia * fatias;
  int nFaces = fatias * (pontosPorFatia - 1);

  pontos.println("ply");
  pontos.println("format ascii 1.0");
  pontos.println("element vertex " + nVertices);
  pontos.println("property float x");
  pontos.println("property float y");
  pontos.println("property float z");
  pontos.println("element face " + nFaces);
  pontos.println("property list uchar int vertex_index");
  pontos.println("end_header");

  /*
  @brief: Função que gera e escreve os vértices rotacionados (sólido de revolução)
          Usando a fórmula para rotação com deslocamento angular inicial
  */
  float theta = TWO_PI / fatias;
  float deslocamentoInicial = theta / 2.0; 

  for (int j = 0; j < fatias; j++) {
    float ang = deslocamentoInicial + (j * theta); 
    
    for (int i = 0; i < pontosPorFatia; i++) {
      float x0 = perfilSuave[i][0];
      float y0 = perfilSuave[i][1];
      float z0 = perfilSuave[i][2];
      
      float x = cos(ang) * x0 + sin(ang) * z0;
      float y = y0;
      float z = -sin(ang) * x0 + cos(ang) * z0;
      
      pontos.println(x + " " + y + " " + z);
    }
  }

  //Função que gera e escreve os índices das faces (quadriláteros)
  for (int k = 0; k < fatias; k++) {
    int proximaFatia = (k + 1) % fatias; 
    for (int l = 0; l < pontosPorFatia - 1; l++) {
      int v1 = k * pontosPorFatia + l;
      int v2 = k * pontosPorFatia + (l + 1);
      int v3 = proximaFatia * pontosPorFatia + (l + 1);
      int v4 = proximaFatia * pontosPorFatia + l;
      
      pontos.println("4 " + v4 + " " + v3 + " " + v2 + " " + v1);
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
