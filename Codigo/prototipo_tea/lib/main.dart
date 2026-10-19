import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AprendoJugandoApp());
}

//

class Palabra {
  String palabra;
  String imagen;
  List<String> silabas;

  Palabra({required this.palabra, required this.imagen, required this.silabas});

  Map<String, dynamic> toJson() {
    return {'palabra': palabra, 'imagen': imagen, 'silabas': silabas};
  }

  factory Palabra.fromJson(Map<String, dynamic> json) {
    return Palabra(
      palabra: json['palabra'] ?? '',
      imagen: json['imagen'] ?? '📝',
      silabas: List<String>.from(json['silabas'] ?? []),
    );
  }
}

// ============================================================
// APP PRINCIPAL
// ============================================================

class AprendoJugandoApp extends StatelessWidget {
  const AprendoJugandoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aprendo Jugando',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B7DB1),
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF263238),
          centerTitle: true,
          elevation: 0,

          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF263238),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 56),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(120, 56),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),

      home: const InicioPage(),
    );
  }
}

// ============================================================
// PÁGINA PRINCIPAL
// ============================================================

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final FlutterTts flutterTts = FlutterTts();

  List<Palabra> palabras = [];

  int puntos = 0;
  int paginaActual = 0;

  @override
  void initState() {
    super.initState();

    configurarVoz();
    cargarPalabras();
  }

  // ==========================================================
  // CONFIGURACIÓN DE VOZ
  // ==========================================================

  Future<void> configurarVoz() async {
    try {
      await flutterTts.setLanguage('es-ES');
      await flutterTts.setSpeechRate(0.42);
      await flutterTts.setPitch(1.35);
      await flutterTts.setVolume(1.0);

      await flutterTts.awaitSpeakCompletion(false);

      List<dynamic> voices = await flutterTts.getVoices;

      for (var voice in voices) {
        if (voice is Map) {
          String name = voice['name']?.toString().toLowerCase() ?? '';

          String locale = voice['locale']?.toString().toLowerCase() ?? '';

          if (locale.contains('es') &&
              (name.contains('female') ||
                  name.contains('femenino') ||
                  name.contains('monica') ||
                  name.contains('lucia') ||
                  name.contains('paulina'))) {
            await flutterTts.setVoice({
              'name': voice['name'],
              'locale': voice['locale'],
            });

            break;
          }
        }
      }
    } catch (_) {}
  }

  // ==========================================================
  // HABLAR
  // ==========================================================

  Future<void> hablar(String texto) async {
    if (texto.trim().isEmpty) return;

    try {
      await flutterTts.stop();

      final textoParaHablar = prepararTexto(texto);

      await flutterTts.speak(textoParaHablar);
    } catch (_) {}
  }

  // ==========================================================
  // PREPARAR TEXTO
  // ==========================================================

  String prepararTexto(String texto) {
    String textoAjustado = texto.trim().toLowerCase();

    Map<String, String> foneticaExacta = {
      'sa': 'sá',
      'se': 'sé',
      'si': 'sí',
      'so': 'só',
      'su': 'sú',

      'za': 'zá',
      'ze': 'zé',
      'zi': 'zí',
      'zo': 'zó',
      'zu': 'zú',

      'ca': 'cá',
      'ce': 'cé',
      'ci': 'cí',
      'co': 'có',
      'cu': 'cú',

      'ma': 'má',
      'me': 'mé',
      'mi': 'mí',
      'mo': 'mó',
      'mu': 'mú',

      'pa': 'pá',
      'pe': 'pé',
      'pi': 'pí',
      'po': 'pó',
      'pu': 'pú',

      'ta': 'tá',
      'te': 'té',
      'ti': 'tí',
      'to': 'tó',
      'tu': 'tú',

      'ga': 'gá',
      'ge': 'gé',
      'gi': 'gí',
      'go': 'gó',
      'gu': 'gú',

      'la': 'lá',
      'le': 'lé',
      'li': 'lí',
      'lo': 'ló',
      'lu': 'lú',

      'na': 'ná',
      'ne': 'né',
      'ni': 'ní',
      'no': 'nó',
      'nu': 'nú',

      'ra': 'rá',
      're': 'ré',
      'ri': 'rí',
      'ro': 'ró',
      'ru': 'rú',
    };

    if (foneticaExacta.containsKey(textoAjustado)) {
      return foneticaExacta[textoAjustado]!;
    }

    if (textoAjustado.length == 1) {
      return '$textoAjustado.';
    }

    return textoAjustado;
  }

  // ==========================================================
  // PALABRAS INICIALES
  // ==========================================================

  List<Palabra> palabrasIniciales() {
    return [
      Palabra(palabra: 'MANZANA', imagen: '🍎', silabas: ['MAN', 'ZA', 'NA']),

      Palabra(palabra: 'PELOTA', imagen: '⚽', silabas: ['PE', 'LO', 'TA']),

      Palabra(palabra: 'GATO', imagen: '🐱', silabas: ['GA', 'TO']),

      Palabra(palabra: 'CASA', imagen: '🏠', silabas: ['CA', 'SA']),

      Palabra(
        palabra: 'MARIPOSA',
        imagen: '🦋',
        silabas: ['MA', 'RI', 'PO', 'SA'],
      ),
    ];
  }

  // ==========================================================
  // CARGAR PALABRAS
  // ==========================================================

  Future<void> cargarPalabras() async {
    final prefs = await SharedPreferences.getInstance();

    final datos = prefs.getString('palabrasTEA');

    if (datos == null) {
      setState(() {
        palabras = palabrasIniciales();
      });

      await guardarPalabras();
    } else {
      try {
        final lista = jsonDecode(datos) as List;

        setState(() {
          palabras = lista.map((item) => Palabra.fromJson(item)).toList();
        });
      } catch (_) {
        setState(() {
          palabras = palabrasIniciales();
        });
      }
    }
  }

  // ==========================================================
  // GUARDAR PALABRAS
  // ==========================================================

  Future<void> guardarPalabras() async {
    final prefs = await SharedPreferences.getInstance();

    final datos = jsonEncode(
      palabras.map((palabra) => palabra.toJson()).toList(),
    );

    await prefs.setString('palabrasTEA', datos);
  }

  // ==========================================================
  // AGREGAR PALABRA
  // ==========================================================

  Future<void> agregarPalabra(Palabra nueva) async {
    setState(() {
      palabras.add(nueva);
    });

    await guardarPalabras();
  }

  // ==========================================================
  // MODIFICAR PALABRA
  // ==========================================================

  Future<void> modificarPalabra(int indice, Palabra nueva) async {
    setState(() {
      palabras[indice] = nueva;
    });

    await guardarPalabras();
  }

  // ==========================================================
  // ELIMINAR PALABRA
  // ==========================================================

  Future<void> eliminarPalabra(int indice) async {
    setState(() {
      palabras.removeAt(indice);
    });

    await guardarPalabras();
  }

  // ==========================================================
  // SUMAR PUNTOS
  // ==========================================================

  void sumarPuntos() {
    setState(() {
      puntos += 10;
    });
  }

  // ==========================================================
  // PÁGINAS
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (palabras.isEmpty) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    final paginas = [
      ActividadPage(
        palabras: palabras,
        puntos: puntos,
        onSumarPuntos: sumarPuntos,
        hablar: hablar,
      ),

      ListaLecturaPage(palabras: palabras, hablar: hablar),

      GestionPalabrasPage(
        palabras: palabras,
        onAgregar: agregarPalabra,
        onModificar: modificarPalabra,
        onEliminar: eliminarPalabra,
      ),
    ];

    return Scaffold(
      body: paginas[paginaActual],

      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaActual,

        onDestinationSelected: (index) {
          setState(() {
            paginaActual = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            selectedIcon: Icon(Icons.extension),
            label: 'Actividad',
          ),

          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Palabras',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Gestionar',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTIVIDAD
// ============================================================

class ActividadPage extends StatefulWidget {
  final List<Palabra> palabras;
  final int puntos;
  final VoidCallback onSumarPuntos;
  final Future<void> Function(String) hablar;

  const ActividadPage({
    super.key,
    required this.palabras,
    required this.puntos,
    required this.onSumarPuntos,
    required this.hablar,
  });

  @override
  State<ActividadPage> createState() => _ActividadPageState();
}

class _ActividadPageState extends State<ActividadPage> {
  int indicePalabra = 0;

  List<String> silabasDisponibles = [];
  List<String> respuesta = [];

  bool palabraCorrecta = false;
  String mensaje = '';

  final Random random = Random();

  @override
  void initState() {
    super.initState();

    prepararActividad();
  }

  void prepararActividad() {
    if (widget.palabras.isEmpty) return;

    final palabra = widget.palabras[indicePalabra];

    silabasDisponibles = List<String>.from(palabra.silabas);

    silabasDisponibles.shuffle(random);

    respuesta = [];

    palabraCorrecta = false;

    mensaje = '';

    setState(() {});
  }

  void seleccionarSilaba(String silaba) {
    if (palabraCorrecta) return;

    setState(() {
      respuesta.add(silaba);

      final indice = silabasDisponibles.indexOf(silaba);

      if (indice != -1) {
        silabasDisponibles.removeAt(indice);
      }
    });

    widget.hablar(silaba);
  }

  void borrarUltima() {
    if (respuesta.isEmpty || palabraCorrecta) return;

    final ultima = respuesta.removeLast();

    setState(() {
      silabasDisponibles.add(ultima);
    });
  }

  void comprobar() {
    final palabra = widget.palabras[indicePalabra];

    if (respuesta.length != palabra.silabas.length) {
      setState(() {
        mensaje = 'Faltan sílabas';
      });

      return;
    }

    final correcta = _listasIguales(respuesta, palabra.silabas);

    if (correcta) {
      setState(() {
        palabraCorrecta = true;

        mensaje = '¡Muy bien!';
      });

      widget.onSumarPuntos();

      widget.hablar(palabra.palabra);
    } else {
      setState(() {
        mensaje = 'Todavía no. Probá nuevamente.';
      });
    }
  }

  bool _listasIguales(List<String> lista1, List<String> lista2) {
    if (lista1.length != lista2.length) {
      return false;
    }

    for (int i = 0; i < lista1.length; i++) {
      if (lista1[i].toUpperCase() != lista2[i].toUpperCase()) {
        return false;
      }
    }

    return true;
  }

  void siguientePalabra() {
    if (widget.palabras.isEmpty) return;

    setState(() {
      indicePalabra++;

      if (indicePalabra >= widget.palabras.length) {
        indicePalabra = 0;
      }
    });

    prepararActividad();
  }

  String palabraArmada() {
    return respuesta.join('');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.palabras.isEmpty) {
      return const Center(
        child: Text(
          'No hay palabras disponibles',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    final palabra = widget.palabras[indicePalabra];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),

        child: Column(
          children: [
            const Text(
              'Formá la palabra',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Tocá las sílabas en orden',
              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 18, color: Color(0xFF607D8B)),
            ),

            const SizedBox(height: 22),

            Container(
              width: 150,
              height: 150,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: const Color(0xFFE0E5EA), width: 1.5),
              ),

              child: Center(
                child: Text(
                  palabraCorrecta ? palabra.imagen : '❓',

                  style: TextStyle(fontSize: palabraCorrecta ? 78 : 65),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(14),

                border: Border.all(color: const Color(0xFFE0E5EA)),
              ),

              child: Column(
                children: [
                  const Text(
                    'Tu palabra',

                    style: TextStyle(fontSize: 15, color: Color(0xFF607D8B)),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    palabraArmada().isEmpty ? '_____' : palabraArmada(),

                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'Elegí una sílaba:',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,

              children: silabasDisponibles.map((silaba) {
                return SizedBox(
                  width: 110,
                  height: 62,

                  child: ElevatedButton(
                    onPressed: palabraCorrecta
                        ? null
                        : () => seleccionarSilaba(silaba),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,

                      foregroundColor: const Color(0xFF263238),

                      elevation: 0,

                      side: const BorderSide(
                        color: Color(0xFFD5DCE3),
                        width: 1.5,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      padding: EdgeInsets.zero,
                    ),

                    child: Text(
                      silaba,

                      maxLines: 1,

                      softWrap: false,

                      overflow: TextOverflow.visible,

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 22),

            if (mensaje.isNotEmpty)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),

                decoration: BoxDecoration(
                  color: palabraCorrecta
                      ? const Color(0xFFE4F5E9)
                      : const Color(0xFFFFF4DD),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Text(
                  mensaje,

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 19,

                    fontWeight: FontWeight.bold,

                    color: palabraCorrecta
                        ? const Color(0xFF246B3A)
                        : const Color(0xFF8A5A00),
                  ),
                ),
              ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  flex: 2,

                  child: SizedBox(
                    height: 62,

                    child: OutlinedButton.icon(
                      onPressed: palabraCorrecta ? null : borrarUltima,

                      icon: const Icon(Icons.backspace_outlined, size: 24),

                      label: const Text(
                        'Borrar',

                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF9EA7B0),
                          width: 1.3,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  flex: 2,

                  child: SizedBox(
                    height: 62,

                    child: ElevatedButton.icon(
                      onPressed: palabraCorrecta ? siguientePalabra : comprobar,

                      icon: Icon(
                        palabraCorrecta ? Icons.arrow_forward : Icons.check,

                        size: 24,
                      ),

                      label: Text(
                        palabraCorrecta ? 'Siguiente' : 'Comprobar',

                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7DB1),

                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PÁGINA DE PALABRAS
// ============================================================

class ListaLecturaPage extends StatelessWidget {
  final List<Palabra> palabras;

  final Future<void> Function(String) hablar;

  const ListaLecturaPage({
    super.key,
    required this.palabras,
    required this.hablar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Palabras')),

      body: GridView.builder(
        // CAMBIO: menos espacio exterior
        padding: const EdgeInsets.all(12),

        // CAMBIO:
        // Ahora entran 3 tarjetas por fila
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,

          crossAxisSpacing: 10,

          mainAxisSpacing: 10,

          // Tarjetas más compactas
          childAspectRatio: 1.15,
        ),

        itemCount: palabras.length,

        itemBuilder: (context, index) {
          final item = palabras[index];

          return Card(
            elevation: 0,

            color: Colors.white,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),

              side: const BorderSide(color: Color(0xFFE0E5EA)),
            ),

            child: InkWell(
              borderRadius: BorderRadius.circular(14),

              onTap: () => hablar(item.palabra),

              child: Padding(
                padding: const EdgeInsets.all(8),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    // IMAGEN MÁS PEQUEÑA
                    Text(item.imagen, style: const TextStyle(fontSize: 40)),

                    const SizedBox(height: 6),

                    // NOMBRE MÁS COMPACTO
                    Text(
                      item.palabra,

                      textAlign: TextAlign.center,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(Icons.volume_up_outlined, size: 17),

                        SizedBox(width: 4),

                        Text('Escuchar', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// GESTIÓN DE PALABRAS
// ============================================================

class GestionPalabrasPage extends StatelessWidget {
  final List<Palabra> palabras;

  final Function(Palabra) onAgregar;

  final Function(int, Palabra) onModificar;

  final Function(int) onEliminar;

  const GestionPalabrasPage({
    super.key,
    required this.palabras,
    required this.onAgregar,
    required this.onModificar,
    required this.onEliminar,
  });

  void _abrirFormulario(BuildContext context, {int? index}) {
    showDialog(
      context: context,

      builder: (context) => FormularioPalabraDialog(
        palabraOriginal: index != null ? palabras[index] : null,

        onGuardar: (palabra) {
          if (index != null) {
            onModificar(index, palabra);
          } else {
            onAgregar(palabra);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar palabras')),

      body: palabras.isEmpty
          ? const Center(
              child: Text('No hay palabras.', style: TextStyle(fontSize: 20)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),

              itemCount: palabras.length,

              itemBuilder: (context, index) {
                final item = palabras[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),

                  color: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),

                    side: const BorderSide(color: Color(0xFFE0E5EA)),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),

                    child: ListTile(
                      leading: SizedBox(
                        width: 48,

                        child: Text(
                          item.imagen,

                          style: const TextStyle(fontSize: 34),
                        ),
                      ),

                      title: Text(
                        item.palabra,

                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),

                        child: Text(
                          item.silabas.join(' - '),

                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          IconButton(
                            tooltip: 'Editar',

                            icon: const Icon(Icons.edit_outlined, size: 28),

                            onPressed: () =>
                                _abrirFormulario(context, index: index),
                          ),

                          IconButton(
                            tooltip: 'Eliminar',

                            icon: const Icon(Icons.delete_outline, size: 28),

                            onPressed: () => onEliminar(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),

        icon: const Icon(Icons.add),

        label: const Text(
          'Nueva palabra',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ============================================================
// FORMULARIO DE PALABRA
// ============================================================

class FormularioPalabraDialog extends StatefulWidget {
  final Palabra? palabraOriginal;

  final Function(Palabra) onGuardar;

  const FormularioPalabraDialog({
    super.key,
    this.palabraOriginal,
    required this.onGuardar,
  });

  @override
  State<FormularioPalabraDialog> createState() =>
      _FormularioPalabraDialogState();
}

class _FormularioPalabraDialogState extends State<FormularioPalabraDialog> {
  late TextEditingController _palabraController;

  late TextEditingController _imagenController;

  late TextEditingController _silabasController;

  @override
  void initState() {
    super.initState();

    _palabraController = TextEditingController(
      text: widget.palabraOriginal?.palabra ?? '',
    );

    _imagenController = TextEditingController(
      text: widget.palabraOriginal?.imagen ?? '📝',
    );

    _silabasController = TextEditingController(
      text: widget.palabraOriginal?.silabas.join(',') ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final esNueva = widget.palabraOriginal == null;

    return AlertDialog(
      title: Text(esNueva ? 'Nueva palabra' : 'Editar palabra'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: _palabraController,

              decoration: const InputDecoration(
                labelText: 'Palabra',

                hintText: 'Ejemplo: PERRO',

                prefixIcon: Icon(Icons.text_fields),
              ),

              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _imagenController,

              decoration: const InputDecoration(
                labelText: 'Imagen',

                hintText: 'Ejemplo: 🐶',

                prefixIcon: Icon(Icons.image_outlined),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _silabasController,

              decoration: const InputDecoration(
                labelText: 'Sílabas',

                hintText: 'Ejemplo: PE,RRO',

                prefixIcon: Icon(Icons.view_module_outlined),
              ),

              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text('Cancelar', style: TextStyle(fontSize: 17)),
        ),

        ElevatedButton(
          onPressed: () {
            if (_palabraController.text.trim().isEmpty) {
              return;
            }

            final silabas = _silabasController.text
                .split(',')
                .map((s) => s.trim().toUpperCase())
                .where((s) => s.isNotEmpty)
                .toList();

            final nueva = Palabra(
              palabra: _palabraController.text.trim().toUpperCase(),

              imagen: _imagenController.text.trim().isEmpty
                  ? '📝'
                  : _imagenController.text.trim(),

              silabas: silabas,
            );

            widget.onGuardar(nueva);

            Navigator.pop(context);
          },

          child: const Text('Guardar', style: TextStyle(fontSize: 17)),
        ),
      ],
    );
  }
}
