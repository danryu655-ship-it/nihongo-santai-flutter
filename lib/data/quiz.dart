// Data diekstrak otomatis dari app/index.html (QUIZ baris 1134).
// Jangan edit manual — jalankan ulang tools/extract-data.mjs bila sumber berubah.

/// Satu soal kuis travel N5.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  /// Pertanyaan (field `q`).
  final String question;

  /// Pilihan jawaban (field `o`).
  final List<String> options;

  /// Indeks jawaban benar (field `a`).
  final int answerIndex;
}

/// Kuis travel N5 (10 soal).
const List<QuizQuestion> travelQuiz = [
  QuizQuestion(question: "「トイレはどこですか。」 artinya apa?", options: ["Di mana toilet?", "Berapa harganya?", "Saya mau yang ini", "Selamat pagi"], answerIndex: 0),
  QuizQuestion(question: "「ありがとうございます」 artinya apa?", options: ["Maafkan saya", "Terima kasih", "Selamat tinggal", "Saya tidak mengerti"], answerIndex: 1),
  QuizQuestion(question: "Kata 「駅」(えき) artinya apa?", options: ["Bandara", "Hotel", "Stasiun", "Restoran"], answerIndex: 2),
  QuizQuestion(question: "「おいしいです」 artinya apa?", options: ["Mahal", "Enak", "Pedas", "Dingin"], answerIndex: 1),
  QuizQuestion(question: "「いくらですか」 dipakai untuk apa?", options: ["Menanyakan arah", "Menanyakan harga", "Memesan makanan", "Minta tolong"], answerIndex: 1),
  QuizQuestion(question: "「すみません」 artinya apa?", options: ["Terima kasih", "Selamat malam", "Permisi · Maaf", "Sampai jumpa"], answerIndex: 2),
  QuizQuestion(question: "Kata 「水」(みず) artinya apa?", options: ["Api", "Air", "Nasi", "Teh"], answerIndex: 1),
  QuizQuestion(question: "「お会計をお願いします」 artinya apa?", options: ["Minta menu", "Minta air", "Minta kantong", "Minta bon / tagihan"], answerIndex: 3),
  QuizQuestion(question: "Kata 「右」(みぎ) artinya apa?", options: ["Kiri", "Lurus", "Belakang", "Kanan"], answerIndex: 3),
  QuizQuestion(question: "「助けてください」 artinya apa?", options: ["Selamat pagi", "Saya mau yang ini", "Berapa harganya?", "Tolong saya!"], answerIndex: 3),
];
