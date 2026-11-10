import 'package:flutter/material.dart';

class StudentResource {
  final String id;
  final String title;
  final String url;
  final String description;
  final String category;
  final String iconEmoji;
  final Color accentColor;

  const StudentResource({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.category,
    required this.iconEmoji,
    required this.accentColor,
  });
}

const List<StudentResource> kStudentResources = [
  StudentResource(
    id: 'manual-guardianes',
    title: 'Manual de Guardianes',
    url: 'https://xurl.es/manualCUA',
    description:
        'Guía completa con protocolos, responsabilidades y lineamientos operativos para guardianes.',
    category: 'Manuales',
    iconEmoji: '📚',
    accentColor: Color(0xFF10B981),
  ),
  StudentResource(
    id: 'diapos-capacitacion',
    title: 'Diapos y Material de Capacitación',
    url: 'https://acortar.link/gWVHrb',
    description:
        'Presentaciones oficiales, diapositivas de inducción y material formativo interactivo.',
    category: 'Capacitación',
    iconEmoji: '🗓️',
    accentColor: Color(0xFF0F766E),
  ),
  StudentResource(
    id: 'glosario-salas',
    title: 'Glosario de Términos de las Salas en Inglés',
    url: 'https://xurl.es/glosarioCUA',
    description:
        'Vocabulario especializado, traducción y pronunciación de conceptos de salas en inglés.',
    category: 'Capacitación',
    iconEmoji: '📓',
    accentColor: Color(0xFF0284C7),
  ),
  StudentResource(
    id: 'paquete-grafico',
    title: 'Paquete Gráfico',
    url:
        'https://drive.google.com/drive/folders/1VZZBLRfqvE3ExVAwNNGPoUrSSDukYBoN?usp=sharing',
    description:
        'Recursos visuales institucionales, logotipos oficiales, elementos de diseño y plantillas.',
    category: 'Herramientas',
    iconEmoji: '💻',
    accentColor: Color(0xFF0C3C4C),
  ),
  StudentResource(
    id: 'cuento-rios-hermanos',
    title: 'Cuento: Ríos Hermanos',
    url: 'https://xurl.es/RiosHermanosCuento',
    description:
        'Narrativa y material didáctico del cuento Ríos Hermanos para actividades y dinámicas.',
    category: 'Didáctico',
    iconEmoji: '🌊',
    accentColor: Color(0xFF06B6D4),
  ),
  StudentResource(
    id: 'casita-agua-movil',
    title: 'Casita del Agua Móvil',
    url: 'https://acortar.link/NeIJR3',
    description:
        'Dinámicas, guías de operación y contenidos del proyecto interactivo Casita del Agua móvil.',
    category: 'Didáctico',
    iconEmoji: '👩🏾‍🏫',
    accentColor: Color(0xFFF59E0B),
  ),
  StudentResource(
    id: 'totem-vestibulo',
    title: 'Visualizar Tótem de Vestíbulo',
    url: 'https://xurl.es/totem',
    description:
        'Acceso interactivo a la interfaz y visualización de contenidos en pantalla de vestíbulo.',
    category: 'Herramientas',
    iconEmoji: '📺',
    accentColor: Color(0xFFF43F5E),
  ),
  StudentResource(
    id: 'discurso-agua-extraterrestre',
    title: 'Discurso Taller: El Agua es Extraterrestre',
    url:
        'https://drive.google.com/file/d/1XexampleDiscursoAgua/view?usp=sharing',
    description:
        'Guión discursivo y material didáctico oficial para el taller interactivo sobre el origen cósmico del agua.',
    category: 'Didáctico',
    iconEmoji: '🪐',
    accentColor: Color(0xFF14B8A6),
  ),
];

const List<String> kResourceCategories = [
  'Todos',
  'Capacitación',
  'Manuales',
  'Didáctico',
  'Herramientas',
];

