import 'package:flutter/foundation.dart';
import '../../../../core/services/auth_service.dart';
import '../domain/cover_letter_model.dart';

/// CoverLetterDatasource handles all cover-letter API calls.
class CoverLetterDatasource {
  // ── Curated Local Fallback Templates ───────────────────────────────────────
  static const List<CoverLetterTemplate> fallbackTemplates = [
    CoverLetterTemplate(
      id: 'standard_professional',
      title: 'Standard Professional',
      header: '[Your Name]\n[Phone Number] | [Email Address] | [City, Country]\n[LinkedIn Profile URL]\n\nHiring Team\n[Company Name]\n[Company Address]',
      body: 'Dear Hiring Manager,\n\nI am writing to express my strong interest in the [Target Position] role at [Company Name]. With a solid track record in my field and proven expertise in key industry competencies, I am excited about the opportunity to contribute to your team\'s upcoming initiatives.\n\nThroughout my career, I have consistently focused on delivering measurable outcomes, streamlining workflows, and collaborating effectively across cross-functional teams. My experience aligns closely with the core requirements outlined in your job posting, particularly in problem-solving and driving project success.\n\nI admire [Company Name]\'s leadership and values in this industry, and I welcome the chance to discuss how my skill set and proactive mindset can support your objectives.\n\nThank you for your time and consideration.',
      footer: 'Sincerely,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'modern_corporate',
      title: 'Modern Corporate',
      header: '[Your Full Name]\n[Your Professional Title]\n[Email Address] • [Phone Number] • [City, State]\n\nTo:\nRecruitment Department\n[Target Enterprise Name]\n[Office Address]',
      body: 'Dear Recruiting Team,\n\nI am submitting my candidacy for the [Position Title] position currently open at [Target Enterprise Name]. Having followed your organization\'s recent milestones, I am eager to leverage my professional background to help accelerate your growth.\n\nIn my previous roles, I have spearheaded strategic projects that enhanced operational efficiency, reduced overhead, and strengthened client relationships. I take pride in combining data-driven decision-making with high-impact stakeholder communication.\n\nI am confident that my qualifications will enable me to hit the ground running and make an immediate positive impact at [Target Enterprise Name].',
      footer: 'Best regards,\n[Your Full Name]',
    ),
    CoverLetterTemplate(
      id: 'tech_developer',
      title: 'Tech & Software Engineer',
      header: '[Your Name]\n[Software Engineer / Tech Role]\nGitHub: github.com/[your-handle] | Portfolio: [your-portfolio.com]\nEmail: [your-email] | Phone: [your-phone]\n\nEngineering Leadership\n[Tech Company Name]',
      body: 'Dear Engineering Hiring Manager,\n\nI am thrilled to apply for the [Software Engineer / Tech Role] position at [Tech Company Name]. As a passionate technologist experienced in designing scalable systems, clean architecture, and modern application stacks, I have long admired your engineering culture and product excellence.\n\nKey achievements from my recent work include:\n• Designing resilient services and responsive frontends with test-driven development.\n• Optimizing database queries and caching layers to decrease response latency.\n• Collaborating in Agile sprints with continuous integration and deployment pipelines.\n\nI look forward to discussing how my technical skills and dedication to craftsmanship can contribute to your engineering roadmaps.',
      footer: 'Warm regards,\n[Your Name]\n[Portfolio Link]',
    ),
    CoverLetterTemplate(
      id: 'academic_research',
      title: 'Academic & Research',
      header: '[Your Name], [Degree]\n[Department / Faculty / Institution]\n[Email Address] | [Phone Number]\n\nSearch Committee Chair\n[University / Research Center Name]',
      body: 'Dear Members of the Search Committee,\n\nI am writing to apply for the [Position / Fellowship / Lecturer Role] within the [Department Name] at [University / Institution Name]. My academic training, peer-reviewed publications, and dedication to innovative inquiry equip me to make meaningful contributions to your scholarly community.\n\nMy primary research focuses on [Your Core Research Topic], investigating critical questions that bridge theoretical models and empirical evidence. Alongside my research, I possess a passionate teaching philosophy centered on student mentorship and inclusive classroom discourse.\n\nI would be honored to advance both my research agenda and pedagogical contributions at [University / Institution Name].',
      footer: 'Respectfully yours,\n[Your Name], [Your Degree]',
    ),
    CoverLetterTemplate(
      id: 'career_change',
      title: 'Career Change & Pivot',
      header: '[Your Name]\n[Phone Number] | [Email Address] | [Location]\n\nTalent Acquisition\n[Company Name]',
      body: 'Dear Hiring Manager,\n\nI am writing to present my application for the [Desired Role] position at [Company Name]. While my earlier career developed in [Previous Industry/Field], my intensive training, relevant projects, and adaptable skill set position me uniquely to bring a fresh, multidisciplinary perspective to your organization.\n\nThroughout my prior experience, I mastered fundamental transferable capabilities including analytical reasoning, crisis management, cross-functional leadership, and rigorous project delivery. Having recently deepened my technical and practical expertise in [New Field], I am energized to direct these capabilities toward your team\'s goals.\n\nI welcome the opportunity to discuss how my diverse perspective and dedication will add distinct value to [Company Name].',
      footer: 'Sincerely,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'entry_level_graduate',
      title: 'Entry Level & Graduate',
      header: '[Your Name]\nRecent Graduate in [Your Major]\n[Phone Number] | [Email Address] | [City, Country]\n\nCampus Recruitment / HR Team\n[Company Name]',
      body: 'Dear HR Team,\n\nI am writing to formally apply for the [Entry-Level / Graduate Trainee Position] at [Company Name]. Having recently completed my degree in [Your Degree / Field] from [Your University] with strong academic standing, I am eager to begin my career with an innovative industry leader.\n\nDuring my academic studies, I undertook hands-on capstone projects, participated in extracurricular leadership roles, and completed internships that honed my organizational and technical abilities. I am a fast learner, highly collaborative, and motivated to take on challenging assignments.\n\nI would relish the opportunity to learn and grow under your experienced leadership while delivering my absolute best work.',
      footer: 'Sincerely,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'executive_leadership',
      title: 'Executive & Leadership',
      header: '[Your Name], [Certifications/Titles]\n[Senior Executive Title]\n[Email Address] | [Phone Number] | [City, State]\nLinkedIn: linkedin.com/in/[profile]\n\nBoard of Directors / Search Committee\n[Organization Name]',
      body: 'Dear Members of the Board and Executive Committee,\n\nI am pleased to submit my credentials for the [Executive Position / Director / VP Role] at [Organization Name]. With over [Number] years of senior management experience directing organizational transformations, revenue expansion, and cross-border teams, I offer strategic leadership aligned with your long-term vision.\n\nMy executive track record centers on building high-performance organizational cultures, navigating complex market shifts, and delivering sustainable enterprise value. I maintain a high commitment to governance, innovation, and transparent stakeholder engagement.\n\nI look forward to discussing the strategic direction of [Organization Name] and how my leadership can drive continued enterprise success.',
      footer: 'With highest regards,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'creative_design',
      title: 'Creative & Design',
      header: '[Your Name]\n[Visual Designer / UI/UX / Creative Specialist]\nPortfolio: [your-portfolio-link.com] | Dribbble/Behance: [profile]\n[Email Address] | [Phone Number]\n\nCreative Direction Team\n[Agency or Studio Name]',
      body: 'Hello Creative Team,\n\nI am excited to apply for the [Creative Role / UI/UX Designer] opportunity at [Agency or Studio Name]. Having admired your bold campaigns, visual identity work, and focus on engaging human experiences, I am enthusiastic about contributing my creative vision to your client roster.\n\nMy design practice focuses on transforming complex concepts into intuitive, visually striking stories. From brand identity systems to responsive digital prototypes, I bring a keen eye for typography, interaction dynamics, and user-centered empathy.\n\nPlease feel free to explore my full interactive portfolio at [portfolio link]. I look forward to connecting and discussing our potential creative collaboration.',
      footer: 'Best regards,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'data_science_ai',
      title: 'Data Science & AI Specialist',
      header: '[Your Name]\nData Scientist & Machine Learning Practitioner\nGitHub / Kaggle: [profile] | Email: [your-email] | Phone: [your-phone]\n\nData Science & Analytics Lead\n[Company Name]',
      body: 'Dear Data Science Hiring Team,\n\nI am writing to submit my application for the [Data Scientist / AI Engineer] position at [Company Name]. With a deep background in statistical modeling, machine learning pipelines, and turning unstructured data into actionable business intelligence, I have followed your organization\'s innovative data initiatives with immense enthusiasm.\n\nIn my recent work, I have designed end-to-end predictive models, implemented natural language processing solutions, and optimized data preprocessing workflows that reduced inference latency. I am passionate about rigorous experimentation, reproducible code, and bridging technical findings to non-technical stakeholders.\n\nI look forward to discussing how my quantitative skill set and model development experience can drive predictive capabilities at [Company Name].',
      footer: 'Warm regards,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'marketing_growth',
      title: 'Marketing & Growth Specialist',
      header: '[Your Full Name]\nGrowth Marketer & Digital Strategist\n[Phone Number] | [Email Address] | [LinkedIn Profile]\n\nMarketing Director\n[Target Company Name]',
      body: 'Dear Marketing Hiring Team,\n\nI am thrilled to apply for the [Marketing Manager / Growth Specialist] role at [Target Company Name]. As an analytical yet creative marketer with expertise across multi-channel campaigns, conversion rate optimization, and brand storytelling, I have long admired your brand presence and market agility.\n\nThroughout my career, I have managed paid performance marketing, SEO, and lifecycle email automation, consistently driving user acquisition while reducing customer acquisition costs (CAC). By coupling data analytics with audience empathy, I help companies turn passive prospects into loyal brand advocates.\n\nI am excited about the opportunity to bring my growth frameworks and creative testing mindset to [Target Company Name].',
      footer: 'Best regards,\n[Your Full Name]',
    ),
    CoverLetterTemplate(
      id: 'finance_banking',
      title: 'Finance, Banking & Accounting',
      header: '[Your Name], [CPA / CFA / Finance Title]\n[Phone Number] | [Email Address] | [City, Country]\n\nFinance Director / Audit Committee\n[Financial Institution / Firm Name]',
      body: 'Dear Finance Hiring Team,\n\nI am writing to express my strong interest in the [Financial Analyst / Accountant / Investment Role] with [Firm Name]. With a solid foundation in financial modeling, variance analysis, regulatory compliance, and fiscal forecasting, I am prepared to deliver rigorous financial stewardship to your organization.\n\nMy background includes analyzing balance sheets, conducting internal financial audits, and developing automated reporting spreadsheets that saved critical reporting hours each quarter. I pride myself on extreme attention to detail, ethical compliance, and identifying cost-saving opportunities.\n\nI welcome the opportunity to discuss how my financial acumen and analytical rigor can support [Firm Name]\'s fiscal health and strategic goals.',
      footer: 'Sincerely,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'remote_worker',
      title: 'Remote & Distributed Team',
      header: '[Your Name]\n[Your Professional Title] (Remote)\nTimezone: UTC+[Offset] | [Email Address] | [Phone Number]\n\nTalent Acquisition\n[Distributed Company Name]',
      body: 'Dear Hiring Team,\n\nI am excited to apply for the [Position Title] position at [Distributed Company Name]. As an experienced remote professional who excels in autonomous execution, asynchronous communication, and cross-timezone collaboration, I am drawn to your mission and distributed team culture.\n\nHaving worked successfully in distributed teams, I am disciplined in project tracking, documentation-first workflows (Notion, Slack, Jira), and self-directed problem resolution. I ensure consistent visibility into deliverables while respecting team rhythms across diverse timezones.\n\nI am confident I can hit the ground running and be a dependable, proactive team player for [Distributed Company Name].',
      footer: 'Warm regards,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'healthcare_medical',
      title: 'Healthcare & Nursing Professional',
      header: '[Your Name], [RN / MBBS / Health Title]\nLicensed Healthcare Professional\n[Phone Number] | [Email Address] | [City, State]\n\nClinical Nurse Manager / Medical Director\n[Hospital / Healthcare Facility Name]',
      body: 'Dear Clinical Hiring Committee,\n\nI am submitting my application for the [Clinical Specialist / Staff Nurse / Medical Role] at [Hospital / Healthcare Facility Name]. Committed to compassionate patient-centered care, clinical safety protocols, and interdisciplinary collaboration, I am eager to contribute to your healthcare community.\n\nMy clinical experience encompasses triaging acute patient needs, administering complex care plans, and maintaining meticulous electronic health records (EHR). I thrive in fast-paced medical environments where empathy, clinical vigilance, and rapid crisis management are essential.\n\nI would be honored to uphold [Hospital / Healthcare Facility Name]\'s dedication to medical excellence and patient well-being.',
      footer: 'Respectfully,\n[Your Name], [Credentials]',
    ),
    CoverLetterTemplate(
      id: 'sales_bd',
      title: 'Sales & Business Development',
      header: '[Your Name]\nBusiness Development & Account Executive\n[Phone Number] | [Email Address] | [LinkedIn Profile]\n\nVP of Sales / Commercial Team\n[Company Name]',
      body: 'Dear Sales Leadership Team,\n\nI am writing to apply for the [Account Executive / Business Development Manager] position at [Company Name]. Driven by consultative selling, relationship building, and exceeding quarterly revenue quotas, I am excited about the opportunity to expand your market share.\n\nIn my previous sales roles, I consistently achieved over 120% of sales targets by identifying high-value enterprise leads, navigating complex procurement cycles, and building trust with C-level stakeholders. I combine CRM discipline with active listening to close deals that create long-term customer lifetime value.\n\nI look forward to discussing how I can accelerate your sales pipeline and deliver immediate revenue growth.',
      footer: 'Best regards,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'customer_success',
      title: 'Customer Success & Support',
      header: '[Your Name]\nCustomer Success & Client Experience Specialist\n[Phone Number] | [Email Address] | [City, Country]\n\nHead of Customer Experience\n[Company Name]',
      body: 'Dear Customer Experience Team,\n\nI am enthusiastic about applying for the [Customer Success Specialist / Support Lead] role at [Company Name]. Passionate about user advocacy, resolving complex customer inquiries, and maximizing client retention, I admire your commitment to stellar customer satisfaction.\n\nMy track record includes reducing customer churn, guiding smooth onboarding experiences, and building comprehensive knowledge-base resources. I maintain a patient, solution-oriented approach even in high-stress customer escalations, ensuring every client feels heard and valued.\n\nI look forward to helping [Company Name] elevate customer satisfaction metrics and foster lasting customer loyalty.',
      footer: 'Sincerely,\n[Your Name]',
    ),
    CoverLetterTemplate(
      id: 'freelance_consultant',
      title: 'Freelancer & Independent Consultant',
      header: '[Your Name]\nStrategic Consultant & Domain Specialist\n[Website / Portfolio URL] | [Email Address] | [Phone Number]\n\nProject Leadership / Executive Team\n[Client Company / Organization]',
      body: 'Dear Leadership Team,\n\nI am pleased to present my proposal and qualifications for the [Consulting / Contract Role] with [Client Company]. With an independent consulting background focused on delivering agile solutions without onboarding friction, I offer strategic clarity and high-velocity execution for your key priorities.\n\nAs an independent consultant, I manage projects from diagnostic analysis through implementation, delivering measurable return on investment while adhering strictly to project scopes and deadlines. I bring cross-industry insights and an objective perspective that drives immediate operational momentum.\n\nI welcome the opportunity to discuss your specific deliverables and how we can achieve exceptional outcomes together.',
      footer: 'With highest regards,\n[Your Name]',
    ),
  ];

  // ── Post Cover Letter ──────────────────────────────────────────────────────

  /// Sends a cover letter to POST /cover-letters.
  /// Returns the saved [SavedCoverLetter] parsed from the response.
  Future<SavedCoverLetter> postCoverLetter(CoverLetterModel model) async {
    final responseMap = await AuthService.authenticatedPost(
      '/cover-letters',
      model.toJson(),
    );

    if (kDebugMode) {
      print("[CoverLetterDatasource] postCoverLetter: $responseMap");
    }

    final data = responseMap['data'] as Map<String, dynamic>? ?? responseMap;
    if (data.containsKey('id') || data.containsKey('_id')) {
      return SavedCoverLetter.fromJson(data);
    }
    throw 'Server returned no data for cover letter.';
  }

  /// Calls GET /cover-letters and returns a list of [SavedCoverLetter].
  Future<List<SavedCoverLetter>> fetchCoverLetters() async {
    final responseMap = await AuthService.authenticatedGet('/cover-letters');

    if (kDebugMode) {
      print("[CoverLetterDatasource] fetchCoverLetters: $responseMap");
    }

    final rawData = responseMap['data'];
    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(SavedCoverLetter.fromJson)
        .toList();
  }

  /// Calls GET /cover-letters/templates to get the list of templates.
  /// Gracefully falls back to curated built-in templates if server is unreachable.
  Future<List<CoverLetterTemplate>> fetchTemplates() async {
    try {
      final responseMap = await AuthService.authenticatedGet('/cover-letters/templates');

      if (kDebugMode) {
        print("[CoverLetterDatasource] fetchTemplates: $responseMap");
      }

      final rawData = responseMap['data'];
      if (rawData is List && rawData.isNotEmpty) {
        return rawData
            .whereType<Map<String, dynamic>>()
            .map(CoverLetterTemplate.fromJson)
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print("[CoverLetterDatasource] Template fetch error: $e. Using local curated templates.");
      }
    }

    return fallbackTemplates;
  }

  /// Calls GET /cover-letters/templates/:id to get the detail of a template.
  Future<CoverLetterTemplate> fetchTemplateDetails(String id) async {
    try {
      final responseMap = await AuthService.authenticatedGet('/cover-letters/templates/$id');

      if (kDebugMode) {
        print("[CoverLetterDatasource] fetchTemplateDetails: $responseMap");
      }

      final data = responseMap['data'] as Map<String, dynamic>?;
      if (data != null) {
        return CoverLetterTemplate.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print("[CoverLetterDatasource] Template details fetch error: $e. Using local fallback.");
      }
    }

    return fallbackTemplates.firstWhere(
      (t) => t.id == id,
      orElse: () => fallbackTemplates.first,
    );
  }
}
