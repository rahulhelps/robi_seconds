import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../domain/sop_model.dart';
import '../domain/sop_repository.dart';
import 'sop_datasource.dart';

class SopRepositoryImpl implements SopRepository {
  final SopDatasource _datasource;

  SopRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, String>> generateSop(SopModel data) async {
    try {
      // First try to check if the datasource generateSop works.
      // If it throws or we want to run local generation for mock/fallback purposes, we can do it.
      // Since this is a template-specific task and local template text generation is key,
      // let's construct the formatted template text directly here, or if we make API request we can fall back to local template.
      // Wait, the API might not support all 10 custom templates that we defined locally.
      // To ensure all 10 templates produce different texts successfully and robustly, we will generate the template text locally
      // (or construct it) if the API fails or doesn't support them.
      // Let's implement local generation representing the specific style tone, order and paragraphs.
      
      final templateId = data.templateId ?? 'classic_academic';
      String header = '';
      String body = '';
      String footer = '';

      switch (templateId) {
        case 'classic_academic':
          header = "To: The Admissions Committee\n"
                   "Program: ${data.programName}\n"
                   "University: ${data.universityName}\n"
                   "Country: ${data.country}\n"
                   "Applicant: ${data.name}\n"
                   "Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
          body = "I am writing to formally express my interest in enrolling in the ${data.programName} at ${data.universityName}. "
                 "As an aspiring scholar, I believe that this program in ${data.country} aligns perfectly with my academic foundations.\n\n"
                 "My academic background is rooted in ${data.academicBackground ?? 'foundational fields of study'}, where I achieved a GPA of ${data.gpa ?? 'N/A'}. "
                 "Throughout my studies, I have developed key skills: ${data.skills ?? 'problem solving and analytical thinking'}. "
                 "These experiences have driven me to seek further specialization.\n\n"
                 "Furthermore, my professional journey has provided me with practical insights. "
                 "${data.workExperience ?? 'I have worked on various industry challenges and internship projects'}. "
                 "Simultaneously, my research endeavors, including ${data.researchExperience ?? 'conducting academic literature reviews and projects'}, have prepared me to undertake rigorous graduate studies.\n\n"
                 "I choose ${data.universityName} because of its academic prestige, excellent curriculum, and alignment with my career goals of ${data.goals ?? 'becoming a leading academic or industry expert'}. "
                 "I am confident that my background, coupled with my achievements such as ${data.achievements ?? 'academic awards'}, will enable me to contribute meaningfully to your institution.";
          footer = "Sincerely,\n\n"
                   "${data.name}";
          break;

        case 'modern_professional':
          header = "SOP FOR ${data.programName.toUpperCase()}\n"
                   "Target: ${data.universityName} (${data.country})\n"
                   "Prepared By: ${data.name}";
          body = "Bridging the gap between academic theories and practical industry challenges has always been my career focus. "
                 "I, ${data.name}, wish to apply for the ${data.programName} at ${data.universityName} in order to build professional mastery.\n\n"
                 "Academic Background & Skills:\n"
                 "With a foundation in ${data.academicBackground ?? 'relevant disciplines'} (GPA: ${data.gpa ?? 'N/A'}), "
                 "I have cultivated professional competencies: ${data.skills ?? 'modern tools and engineering standards'}.\n\n"
                 "Professional Experience & Execution:\n"
                 "${data.workExperience ?? 'My professional experience has exposed me to team collaboration and actual projects'}. "
                 "Additionally, I have engaged in research projects: ${data.researchExperience ?? 'applied case studies and technical design reviews'}.\n\n"
                 "Career Vision & Alignment:\n"
                 "My long-term goal is to ${data.goals ?? 'lead strategic tech projects and innovation'}. "
                 "This program at ${data.universityName} stands out due to its active industry collaborations and modern curriculum. "
                 "I bring a track record of achievement: ${data.achievements ?? 'successful project completions'}, and look forward to contributing to your campus.";
          footer = "Best regards,\n\n"
                   "${data.name}";
          break;

        case 'research_focused':
          header = "RESEARCH STATEMENT & STATEMENT OF PURPOSE\n"
                   "Applicant: ${data.name}\n"
                   "Program: ${data.programName}\n"
                   "Institution: ${data.universityName}, ${data.country}";
          body = "My desire to join the ${data.programName} at ${data.universityName} is driven by a commitment to scientific discovery. "
                 "My main research interests lie at the intersection of ${data.skills ?? 'advanced methodology and system design'}.\n\n"
                 "Academic & Research Foundation:\n"
                 "During my undergraduate studies in ${data.academicBackground ?? 'science and engineering'} (GPA: ${data.gpa ?? 'N/A'}), I realized that independent investigation is key to innovation. "
                 "Specifically, my research experience includes: ${data.researchExperience ?? 'thesis works, data analysis, and laboratory experiments'}.\n\n"
                 "Professional Alignment:\n"
                 "In my professional roles, ${data.workExperience ?? 'I applied scientific principles to resolve technical bugs and pipeline issues'}. "
                 "My accomplishments include ${data.achievements ?? 'publishing papers or presenting in local symposiums'}.\n\n"
                 "Why ${data.universityName}:\n"
                 "I wish to study at ${data.universityName} because of the specific research labs and the country's (${data.country}) scientific environment. "
                 "This aligns with my ultimate career goal: ${data.goals ?? 'working in R&D or pursuing a Ph.D. path'}.";
          footer = "Respectfully submitted,\n\n"
                   "${data.name}";
          break;

        case 'career_change':
          header = "APPLICATION FOR PROGRAM: ${data.programName}\n"
                   "Candidate: ${data.name}\n"
                   "Destination: ${data.universityName} in ${data.country}";
          body = "I am writing to express my candidacy for the ${data.programName} at ${data.universityName}. "
                 "While my background began in another sector, my goal is to transition into this field by leveraging my transferable skills.\n\n"
                 "Professional Background & Motivations:\n"
                 "My background is in ${data.academicBackground ?? 'another industry'} (GPA: ${data.gpa ?? 'N/A'}), "
                 "where I worked on: ${data.workExperience ?? 'various business and coordination roles'}. "
                 "Through these roles, I developed strong transferable skills: ${data.skills ?? 'leadership, strategic management, and analytical modeling'}.\n\n"
                 "Why This Program:\n"
                 "I realized that to succeed in my future goal to ${data.goals ?? 'work as a professional in this new domain'}, "
                 "I need the technical rigor of the ${data.programName} at ${data.universityName}. "
                 "I have already begun self-learning and research: ${data.researchExperience ?? 'foundational courses and hobby projects'}.\n\n"
                 "I bring a unique interdisciplinary perspective, backed by achievements: ${data.achievements ?? 'diverse accomplishments and resilience'}, "
                 "which will add value to the discussions at ${data.universityName}.";
          footer = "Sincerely,\n\n"
                   "${data.name}";
          break;

        case 'engineering_tech':
          header = "TECHNICAL STATEMENT OF PURPOSE\n"
                   "Applicant: ${data.name}\n"
                   "Program: ${data.programName}\n"
                   "University: ${data.universityName} (${data.country})";
          body = "Engineering is about designing solutions to complex problems. "
                 "I wish to apply for the ${data.programName} at ${data.universityName} to advance my technical capabilities in ${data.country}.\n\n"
                 "Technical Foundations:\n"
                 "My background in ${data.academicBackground ?? 'engineering and technology'} (GPA: ${data.gpa ?? 'N/A'}) gave me a strong grasp of core math and sciences. "
                 "My technical skills include: ${data.skills ?? 'software development, hardware modeling, and systems architecture'}.\n\n"
                 "Implementation & Research:\n"
                 "Practically, ${data.workExperience ?? 'I have worked as a developer or engineer, building scalable solutions'}. "
                 "I also have research exposure: ${data.researchExperience ?? 'building prototypes, performing simulations, and reading technical papers'}.\n\n"
                 "Alignment & Future:\n"
                 "The ${data.programName} program at ${data.universityName} is ideal for my goal to ${data.goals ?? 'work as a Chief Technology Officer or lead software architect'}. "
                 "I look forward to utilizing my achievements, such as ${data.achievements ?? 'winning tech hackathons or academic honors'}, to excel in this program.";
          footer = "Sincerely,\n\n"
                   "${data.name}";
          break;

        case 'business_mba':
          header = "EXECUTIVE STATEMENT OF PURPOSE\n"
                   "Candidate: ${data.name}\n"
                   "Program: ${data.programName}\n"
                   "University: ${data.universityName}, ${data.country}";
          body = "In the modern business landscape, strategic leadership requires quantitative analysis. "
                 "I apply for the ${data.programName} at ${data.universityName} to prepare myself for global executive challenges in ${data.country}.\n\n"
                 "Leadership & Work Experience:\n"
                 "My professional career includes: ${data.workExperience ?? 'leading teams, optimizing budgets, and handling project delivery'}. "
                 "Through these roles, I refined key business skills: ${data.skills ?? 'negotiation, finance, strategy, and change management'}.\n\n"
                 "Academic Context:\n"
                 "My academic degree in ${data.academicBackground ?? 'business or related sciences'} (GPA: ${data.gpa ?? 'N/A'}) "
                 "provided me with foundational microeconomics and statistical tools. "
                 "I have also explored research: ${data.researchExperience ?? 'market analysis and strategic research reports'}.\n\n"
                 "Why ${data.universityName} & Goals:\n"
                 "This program aligns with my goal to ${data.goals ?? 'launch a startup or take up a senior management role in a global corporation'}. "
                 "I believe my professional milestones, like ${data.achievements ?? 'scaling business metrics'}, make me a strong fit for the MBA cohort.";
          footer = "Best Regards,\n\n"
                   "${data.name}";
          break;

        case 'medical_health':
          header = "STATEMENT OF PURPOSE: LIFE SCIENCES & MEDICINE\n"
                   "Applicant: ${data.name}\n"
                   "Program: ${data.programName}\n"
                   "Institution: ${data.universityName} (${data.country})";
          body = "My commitment to patient care and clinical excellence drives me to apply for the ${data.programName} at ${data.universityName}. "
                 "I am eager to study in ${data.country} due to its advanced clinical frameworks.\n\n"
                 "Academic & Clinical Background:\n"
                 "My training in ${data.academicBackground ?? 'medical sciences or biotechnology'} (GPA: ${data.gpa ?? 'N/A'}) "
                 "instilled a deep respect for evidence-based medicine. "
                 "My skill set includes: ${data.skills ?? 'clinical diagnostics, patient care, and laboratory protocols'}.\n\n"
                 "Experience & Research:\n"
                 "${data.workExperience ?? 'I have completed hospital internships, worked in local clinics, or assisted in patient management'}. "
                 "Furthermore, I conducted research: ${data.researchExperience ?? 'epidemiological reviews, literature reviews, or lab experiments'}.\n\n"
                 "Why ${data.universityName}:\n"
                 "The medical resources and expert faculty at ${data.universityName} will support my goal of ${data.goals ?? 'becoming a medical researcher or health administrator'}. "
                 "I bring a history of care and achievements: ${data.achievements ?? 'service excellence awards'}, to your student body.";
          footer = "Sincerely,\n\n"
                   "${data.name}";
          break;

        case 'arts_humanities':
          header = "STATEMENT OF PURPOSE: CREATIVE NARRATIVE\n"
                   "Applicant: ${data.name}\n"
                   "Program: ${data.programName}\n"
                   "University: ${data.universityName}, ${data.country}";
          body = "Art and literature define our culture and collective memory. "
                 "I seek admission to the ${data.programName} at ${data.universityName} to deepen my understanding of critical theory.\n\n"
                 "Academic Narrative:\n"
                 "My background in ${data.academicBackground ?? 'liberal arts and humanities'} (GPA: ${data.gpa ?? 'N/A'}) "
                 "focused on critical analysis and writing. "
                 "My creative skills include: ${data.skills ?? 'creative writing, design, and cultural analysis'}.\n\n"
                 "Reflective Experience:\n"
                 "${data.workExperience ?? 'My work has centered around creative media, writing, or curatorial projects'}. "
                 "I also have academic research experience: ${data.researchExperience ?? 'critical essay writing and historical source analysis'}.\n\n"
                 "Why ${data.universityName} & Vision:\n"
                 "The creative atmosphere at ${data.universityName} in ${data.country} is perfect for my goal to ${data.goals ?? 'publish critical texts, teach, or work in arts curation'}. "
                 "I hope to share my achievements: ${data.achievements ?? 'published columns or exhibition works'}, with the humanities department.";
          footer = "Sincerely,\n\n"
                   "${data.name}";
          break;

        case 'international_student':
          header = "STATEMENT OF PURPOSE: GLOBAL PERSPECTIVE\n"
                   "Candidate: ${data.name}\n"
                   "Program: ${data.programName}\n"
                   "University: ${data.universityName} in ${data.country}";
          body = "Studying abroad offers a unique perspective on global cooperation. "
                 "I, ${data.name}, wish to pursue the ${data.programName} at ${data.universityName} in ${data.country}.\n\n"
                 "Academic & Cross-Cultural Background:\n"
                 "Having studied in a diverse academic environment: ${data.academicBackground ?? 'international curriculum'} (GPA: ${data.gpa ?? 'N/A'}), "
                 "I have gained strong adaptabilities: ${data.skills ?? 'intercultural communication, language skills, and global outlook'}.\n\n"
                 "Experience & Global Outlook:\n"
                 "${data.workExperience ?? 'My professional experience includes working with multicultural teams and projects'}. "
                 "I have also engaged in research: ${data.researchExperience ?? 'cross-cultural studies and case analysis'}.\n\n"
                 "Why this Choice:\n"
                 "This program at ${data.universityName} will help me achieve my goal to ${data.goals ?? 'work in multinational organizations or global consulting'}. "
                 "I am ready to bring my achievements: ${data.achievements ?? 'community leadership and international awards'}, to enrich your student group.";
          footer = "Sincerely,\n\n"
                   "${data.name}";
          break;

        case 'scholarship_application':
          header = "STATEMENT OF PURPOSE: SCHOLARSHIP APPLICATION\n"
                   "Applicant: ${data.name}\n"
                   "Program: ${data.programName}\n"
                   "University: ${data.universityName} (${data.country})";
          body = "This statement supports my application for the academic scholarship for the ${data.programName} at ${data.universityName}. "
                 "Receiving this award will enable me to focus on research and community impact in ${data.country}.\n\n"
                 "Academic Merit & Drive:\n"
                 "My academic background in ${data.academicBackground ?? 'foundational sciences'} (GPA: ${data.gpa ?? 'N/A'}) "
                 "highlights my intellectual capacity. "
                 "My specialized skills include: ${data.skills ?? 'analytical execution and academic research'}.\n\n"
                 "Experience & Social Impact:\n"
                 "${data.workExperience ?? 'I have completed social volunteering and industry work'}. "
                 "My research: ${data.researchExperience ?? 'community projects and environmental case studies'} showcases my dedication.\n\n"
                 "Scholarship Impact & Goals:\n"
                 "This funding will support my goal of ${data.goals ?? 'becoming a researcher dedicated to solving public issues'}. "
                 "I bring a record of achievements: ${data.achievements ?? 'excellence awards and leadership roles'}, and pledge to contribute to the academic legacy of ${data.universityName}.";
          footer = "Respectfully,\n\n"
                   "${data.name}";
          break;
      }

      // Format text output locally
      final formattedText = "$header\n\n$body\n\n$footer";
      
      // Fallback or API check:
      try {
        // If API fails or is offline, we catch it and use our formatted text instead.
        // This guarantees the app works perfectly offline or if the API doesn't support custom templates.
        final apiResult = await _datasource.generateSop(data);
        if (apiResult.isNotEmpty) {
          return Right(apiResult);
        }
      } catch (e) {
        print("[SopRepositoryImpl] API failed or offline ($e). Using local template formatter.");
      }

      return Right(formattedText);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SopModel>>> getSopHistory() async {
    try {
      final result = await _datasource.fetchSopHistory();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
