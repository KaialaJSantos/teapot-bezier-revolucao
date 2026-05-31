/*Autores:
César Alberto Bravo Pariente
Kaiala de Jesus Santos
*/

/*
@brief: O seguinte código gera, a partir de pontos de controle Bezier, a malha 3D do corpo do Teapot de Newell
        rotacionando o perfil gerado e exportando o resultado em um arquivo no formato PLY.
        
*/

PrintWriter pontos;

/*
@brief: Vetor bidimensional contendo os pontos de controle do perfil tridimensional do corpo.
        Baseado no esboço de Martin Newell, com vértices mapeados manualmente por Kaiala Santos.
        Contém 7 pontos que formam duas curvas cúbicas conectadas pelo ponto comum v3.
*/
float[][] perfilControle = {
  {2.75, 0.0, 0.0}, //v0
  {2.75, 0.3, 0.0}, //v1
  {3.7, 0.8, 0.0}, //v2
  {3.65, 1.9, 0.0}, //v3
  {3.65, 3.1, 0.0}, //v4
  {3.25, 4.4, 0.0}, //v5
  {2.85, 5.7, 0.0} //v6
};

//Quantidade de divisões rotacionais ao redor do eixo de revolução para gerar a malha 3D.
int fatias = 8; 

//Quantidade de subdivisões por curva de Bézier para amostragem e suavização do perfil.
int passosBezier = 10;

//Quantidade total de pontos gerados no perfil final suavizado.
int pontosPorFatia = (2 * passosBezier) + 1; 

/*
@brief: Configura o ambiente do Processing, realiza o cálculo de amostragem das duas curvas de Bézier por extenso, 
        faz a revolução dos pontos com deslocamento inicial, gera as faces quadrangulares e exporta a malha final no arquivo PLY. 
        Encerra a execução ao finalizar.
*/
void setup() {
  pontos = createWriter("teapotCorpoBezier.ply");
  size(800, 600, P3D);

  float[][] perfilSuave = new float[pontosPorFatia][3];
  int indexPerfil = 0;

  // Curva 1: v0 -> v3
  for (int i = 0; i < passosBezier; i++) {
    float t = i / (float)passosBezier;
    perfilSuave[indexPerfil] = calcularBezierFormula(perfilControle[0], perfilControle[1], perfilControle[2], perfilControle[3], t);
    indexPerfil++;
  }

  // Curva 2: v3 -> v6
  for (int i = 0; i <= passosBezier; i++) {
    float t = i / (float)passosBezier;
    perfilSuave[indexPerfil] = calcularBezierFormula(perfilControle[3], perfilControle[4], perfilControle[5], perfilControle[6], t);
    indexPerfil++;
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
          Usando a fórmula para rotação em torno do eixo Y com deslocamento angular inicial
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
