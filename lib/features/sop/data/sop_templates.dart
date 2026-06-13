import '../domain/sop_template.dart';

final List<SopTemplate> sopTemplates = [
  const SopTemplate(
    id: 'classic_academic',
    name: 'Classic Academic',
    description: 'Traditional formal style suitable for research and academic programs.',
    isPremium: false,
  ),
  const SopTemplate(
    id: 'modern_professional',
    name: 'Modern Professional',
    description: 'Clean contemporary layout ideal for professional and coursework degrees.',
    isPremium: true,
  ),
  const SopTemplate(
    id: 'research_focused',
    name: 'Research Focused',
    description: 'Emphasizes research publications, lab experience, and technical projects.',
    isPremium: false,
  ),
  const SopTemplate(
    id: 'career_change',
    name: 'Career Change',
    description: 'Highlights transferable skills, professional pivot motivations, and background context.',
    isPremium: true,
  ),
  const SopTemplate(
    id: 'engineering_tech',
    name: 'Engineering & Tech',
    description: 'Technical background focused with highlight on engineering design and coding projects.',
    isPremium: false,
  ),
  const SopTemplate(
    id: 'business_mba',
    name: 'Business & MBA',
    description: 'Business-oriented leadership tone focusing on management and entrepreneurial metrics.',
    isPremium: true,
  ),
  const SopTemplate(
    id: 'medical_health',
    name: 'Medical & Healthcare',
    description: 'Healthcare field oriented, emphasizing clinical experience, patient care, and science.',
    isPremium: false,
  ),
  const SopTemplate(
    id: 'arts_humanities',
    name: 'Arts & Humanities',
    description: 'Creative field oriented with reflective narrative and philosophical style.',
    isPremium: true,
  ),
  const SopTemplate(
    id: 'international_student',
    name: 'International Student',
    description: 'Focuses on cross-cultural adaptable motivations and international alignment.',
    isPremium: false,
  ),
  const SopTemplate(
    id: 'scholarship_application',
    name: 'Scholarship Application',
    description: 'Award-focused style highlighting community impact, financial need, and excellence.',
    isPremium: true,
  ),
];
