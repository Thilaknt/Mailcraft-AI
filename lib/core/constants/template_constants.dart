class TemplateData {
  final String title;
  final String description;
  final String recipientType;
  final String tone;
  final String language;
  final String purposeHint;

  const TemplateData({
    required this.title,
    required this.description,
    required this.recipientType,
    required this.tone,
    required this.language,
    required this.purposeHint,
  });
}

const List<TemplateData> appTemplates = [
  TemplateData(
    title: 'Job Application',
    description: 'Craft a professional job application message highlighting qualifications.',
    recipientType: 'HR Manager',
    tone: 'Professional',
    language: 'English',
    purposeHint: 'Apply for the Software Engineer position highlighting 3 years of Flutter experience and passion for scalable web/mobile apps.',
  ),
  TemplateData(
    title: 'Internship Request',
    description: 'Request an internship opportunity in a polite and confident tone.',
    recipientType: 'HR Manager',
    tone: 'Professional',
    language: 'English',
    purposeHint: 'Apply for a software engineering internship with background in Computer Science and mobile app development.',
  ),
  TemplateData(
    title: 'Leave Request',
    description: 'Ask for time off with focus on clear dates and work coverage.',
    recipientType: 'Manager',
    tone: 'Formal',
    language: 'English',
    purposeHint: 'Request leave from Monday to Wednesday next week for personal reasons, ensuring all tasks are handed over.',
  ),
  TemplateData(
    title: 'Meeting Request',
    description: 'Schedule a meeting with a clear agenda and proposed availability.',
    recipientType: 'Colleague',
    tone: 'Professional',
    language: 'English',
    purposeHint: 'Request a 30-minute sync to review product design roadmap and backend deployment timelines.',
  ),
  TemplateData(
    title: 'Project Update',
    description: 'Share project progress, recent wins, and upcoming milestones.',
    recipientType: 'Client',
    tone: 'Professional',
    language: 'English',
    purposeHint: 'Provide progress update on the mobile app development project highlighting completed sprint features.',
  ),
  TemplateData(
    title: 'Thank You',
    description: 'Send a warm and appreciative thank-you message.',
    recipientType: 'Colleague',
    tone: 'Appreciative',
    language: 'English',
    purposeHint: 'Thank the team for their dedication during the product launch release this week.',
  ),
  TemplateData(
    title: 'Apology',
    description: 'Offer a sincere apology while taking responsibility and offering a solution.',
    recipientType: 'Client',
    tone: 'Apologetic',
    language: 'English',
    purposeHint: 'Apologize for the unexpected delay in delivering the weekly analytics report and provide updated ETA.',
  ),
  TemplateData(
    title: 'Follow-up',
    description: 'Check in professionally after an unresolved request or proposal.',
    recipientType: 'Client',
    tone: 'Persuasive',
    language: 'English',
    purposeHint: 'Follow up on the pending contract proposal sent last Tuesday to confirm next steps.',
  ),
  TemplateData(
    title: 'Complaint',
    description: 'Express a concern clearly while requesting a fair resolution.',
    recipientType: 'Customer',
    tone: 'Assertive',
    language: 'English',
    purposeHint: 'Report issue regarding delayed hardware shipment and request expedited delivery or refund.',
  ),
  TemplateData(
    title: 'Invitation',
    description: 'Invite someone with a warm and descriptive event message.',
    recipientType: 'Friend',
    tone: 'Friendly',
    language: 'English',
    purposeHint: 'Invite friends to a weekend trip to Goa with details on accommodation and itinerary.',
  ),
  TemplateData(
    title: 'Birthday',
    description: 'Send a heartfelt birthday celebration message.',
    recipientType: 'Friend',
    tone: 'Friendly',
    language: 'English',
    purposeHint: 'Invite my closest friends to my birthday party celebration this Saturday evening at 7 PM.',
  ),
  TemplateData(
    title: 'Client Update',
    description: 'Provide a concise progress report for a client.',
    recipientType: 'Client',
    tone: 'Professional',
    language: 'English',
    purposeHint: 'Share progress update about the website redesign project and preview demo link.',
  ),
];
