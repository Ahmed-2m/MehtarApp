class Question {
  final String id;
  final String title; // نص السؤال (مثلاً: وش جوك اليوم؟)
  final List<QuestionOption> options; // الخيارات المتاحة للسؤال

  Question({required this.id, required this.title, required this.options});
}

class QuestionOption {
  final String text; // نص الخيار (مثلاً: أكل ثقيل ومشبع)
  final String icon; // أيقونة الخيار
  final String filterKey; // القيمة التي نفلتر بها الوجبات بناءً على الإجابة

  QuestionOption({
    required this.text,
    required this.icon,
    required this.filterKey,
  });
}
