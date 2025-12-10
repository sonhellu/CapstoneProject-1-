class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String content;
  final String category;
  final DateTime publishDate;
  final String author;
  final List<String> tags;
  final bool isFeatured;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.content,
    required this.category,
    required this.publishDate,
    required this.author,
    required this.tags,
    this.isFeatured = false,
  });

  // Sample data for demonstration
  static List<BannerModel> getSampleBanners() {
    return [
      BannerModel(
        id: '1',
        title: 'Welcome to Campus Life',
        subtitle: 'Discover amazing opportunities and events',
        imageUrl: 'https://picsum.photos/800/400?random=1',
        content: '''
Welcome to our amazing campus! Here you'll find everything you need to make the most of your university experience. From academic resources to social events, we've got you covered.

## What's New This Week

- **Orientation Week**: Join us for a week of fun activities and meet new friends
- **Study Groups**: Form study groups for your courses and excel academically
- **Sports Events**: Participate in various sports activities and competitions
- **Cultural Festivals**: Experience diverse cultures through our cultural events

## Getting Started

1. **Explore the Campus**: Take a virtual tour of our facilities
2. **Join Clubs**: Find clubs that match your interests
3. **Academic Support**: Access tutoring and study resources
4. **Career Services**: Get help with internships and job placements

Don't miss out on these amazing opportunities to enhance your university experience!
        ''',
        category: 'Campus Life',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        author: 'Campus Admin',
        tags: ['campus', 'orientation', 'welcome'],
        isFeatured: true,
      ),
      BannerModel(
        id: '2',
        title: 'Academic Excellence Program',
        subtitle: 'Boost your grades with our support programs',
        imageUrl: 'https://picsum.photos/800/400?random=2',
        content: '''
Our Academic Excellence Program is designed to help students achieve their full potential. We offer comprehensive support services to ensure your academic success.

## Program Features

- **Tutoring Services**: One-on-one and group tutoring sessions
- **Study Workshops**: Learn effective study techniques and time management
- **Academic Advising**: Get personalized guidance for your academic journey
- **Peer Mentoring**: Connect with upperclassmen for guidance and support

## How to Join

1. Visit the Academic Support Center
2. Schedule an appointment with an advisor
3. Choose the services that best fit your needs
4. Start your journey to academic excellence

## Success Stories

Many students have improved their grades significantly through our program. Join the hundreds of students who have already benefited from our services!
        ''',
        category: 'Academics',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        author: 'Academic Support Team',
        tags: ['academics', 'tutoring', 'success'],
        isFeatured: true,
      ),
      BannerModel(
        id: '3',
        title: 'International Student Support',
        subtitle: 'Resources and community for international students',
        imageUrl: 'https://picsum.photos/800/400?random=3',
        content: '''
We understand that studying in a new country can be challenging. Our International Student Support program is here to help you navigate your journey and make the most of your experience.

## Support Services

- **Visa and Immigration**: Get help with visa renewals and immigration matters
- **Cultural Integration**: Join cultural exchange programs and events
- **Language Support**: Improve your language skills with our language programs
- **Housing Assistance**: Find suitable accommodation and roommates

## Community Events

- **International Food Festival**: Share your culture through food
- **Language Exchange**: Practice languages with native speakers
- **Cultural Workshops**: Learn about different cultures and traditions
- **Networking Events**: Connect with professionals and alumni

## Getting Help

Our international student advisors are available Monday to Friday, 9 AM to 5 PM. Don't hesitate to reach out for any assistance you need!
        ''',
        category: 'International',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        author: 'International Office',
        tags: ['international', 'support', 'community'],
        isFeatured: false,
      ),
      BannerModel(
        id: '4',
        title: 'Career Development Center',
        subtitle: 'Launch your career with our professional services',
        imageUrl: 'https://picsum.photos/800/400?random=4',
        content: '''
The Career Development Center is your gateway to professional success. We provide comprehensive career services to help you transition from student to professional.

## Our Services

- **Resume Building**: Create professional resumes and cover letters
- **Interview Preparation**: Practice interviews with industry professionals
- **Job Placement**: Access exclusive job opportunities and internships
- **Career Counseling**: Get personalized career guidance and planning

## Industry Connections

We have partnerships with leading companies in various industries:
- Technology and IT
- Finance and Banking
- Healthcare and Medicine
- Engineering and Manufacturing
- Education and Research

## Success Metrics

- 95% of our graduates find employment within 6 months
- Average starting salary increase of 25% for our program participants
- 500+ successful internship placements annually

Start building your professional network today!
        ''',
        category: 'Career',
        publishDate: DateTime.now().subtract(const Duration(days: 7)),
        author: 'Career Services',
        tags: ['career', 'jobs', 'professional'],
        isFeatured: true,
      ),
      BannerModel(
        id: '5',
        title: 'Health and Wellness',
        subtitle: 'Take care of your physical and mental health',
        imageUrl: 'https://picsum.photos/800/400?random=5',
        content: '''
Your health and wellness are our top priorities. We offer comprehensive health services to ensure you stay healthy and happy throughout your academic journey.

## Health Services

- **Medical Clinic**: On-campus medical services and consultations
- **Mental Health Support**: Counseling and therapy services
- **Fitness Programs**: Gym access and fitness classes
- **Nutrition Counseling**: Healthy eating guidance and meal planning

## Wellness Programs

- **Stress Management**: Learn techniques to manage academic stress
- **Sleep Hygiene**: Improve your sleep quality and habits
- **Mindfulness**: Practice meditation and mindfulness techniques
- **Work-Life Balance**: Maintain a healthy balance between studies and life

## Emergency Services

24/7 emergency health services are available. In case of any health emergency, contact our emergency hotline immediately.

Remember: Your health is your wealth. Take care of yourself!
        ''',
        category: 'Health',
        publishDate: DateTime.now().subtract(const Duration(days: 10)),
        author: 'Health Services',
        tags: ['health', 'wellness', 'mental-health'],
        isFeatured: false,
      ),
    ];
  }
}
