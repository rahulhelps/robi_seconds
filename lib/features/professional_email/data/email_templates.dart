import '../domain/email_model.dart';

/// 10 international professional email templates.
final List<EmailTemplate> emailTemplates = [
  const EmailTemplate(
    id: 'corporate_formal',
    name: 'Corporate Formal',
    description: 'Navy header, serif font, classic formal business structure.',
    isPremium: false,
  ),
  const EmailTemplate(
    id: 'modern_minimal',
    name: 'Modern Minimal',
    description: 'Clean white design with thin blue accent line and sans-serif typography.',
    isPremium: false,
  ),
  const EmailTemplate(
    id: 'executive',
    name: 'Executive',
    description: 'Dark charcoal header with two-column sender/date info block.',
    isPremium: true,
  ),
  const EmailTemplate(
    id: 'creative_professional',
    name: 'Creative Professional',
    description: 'Vibrant purple gradient header with bold modern typography.',
    isPremium: true,
  ),
  const EmailTemplate(
    id: 'tech_industry',
    name: 'Tech Industry',
    description: 'Clean grid layout with monospace font accents for tech roles.',
    isPremium: false,
  ),
  const EmailTemplate(
    id: 'academic_research',
    name: 'Academic / Research',
    description: 'Traditional manuscript feel with blue accents for academia.',
    isPremium: false,
  ),
  const EmailTemplate(
    id: 'startup_friendly',
    name: 'Startup Friendly',
    description: 'Bold dark header with amber gold accents and modern layout.',
    isPremium: true,
  ),
  const EmailTemplate(
    id: 'consulting_firm',
    name: 'Consulting Firm',
    description: 'Professional charcoal grid with structured left-accent sections.',
    isPremium: false,
  ),
  const EmailTemplate(
    id: 'healthcare_medical',
    name: 'Healthcare / Medical',
    description: 'Clean clinical white with teal accent for healthcare professionals.',
    isPremium: true,
  ),
  const EmailTemplate(
    id: 'finance_banking',
    name: 'Finance / Banking',
    description: 'Premium dark header with warm gold accents for finance sector.',
    isPremium: true,
  ),
];
