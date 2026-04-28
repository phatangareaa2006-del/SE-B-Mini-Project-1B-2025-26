import { useState, useEffect, useCallback } from "react";
import { useQuery } from "@tanstack/react-query";
import { ChevronLeft, ChevronRight, Clock, CheckCircle, XCircle, Trophy, RotateCcw } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { useAuth } from "@/contexts/AuthContext";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface MockTestTakerProps {
  opportunityId: string;
  onBack: () => void;
}

interface Question {
  id: string;
  question: string;
  options: string[];
  correct_answer: number;
  explanation: string | null;
  difficulty: string | null;
  topic: string | null;
}

type TestPhase = "intro" | "test" | "results";

const MockTestTaker = ({ opportunityId, onBack }: MockTestTakerProps) => {
  const { user } = useAuth();
  const [phase, setPhase] = useState<TestPhase>("intro");
  const [currentQ, setCurrentQ] = useState(0);
  const [answers, setAnswers] = useState<(number | null)[]>([]);
  const [timeElapsed, setTimeElapsed] = useState(0);
  const [showExplanation, setShowExplanation] = useState(false);

  const { data: testInfo } = useQuery({
    queryKey: ["mock-test-info", opportunityId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("opportunities")
        .select("*")
        .eq("id", opportunityId)
        .single();
      if (error) throw error;
      return data;
    },
  });

  const { data: questions, isLoading } = useQuery({
    queryKey: ["mock-test-questions", opportunityId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("mock_test_questions")
        .select("*")
        .eq("opportunity_id", opportunityId)
        .order("created_at");
      if (error) throw error;
      return (data || []).map((q) => ({
        ...q,
        options: typeof q.options === "string" ? JSON.parse(q.options) : q.options,
      })) as Question[];
    },
  });

  // Timer
  useEffect(() => {
    if (phase !== "test") return;
    const interval = setInterval(() => setTimeElapsed((t) => t + 1), 1000);
    return () => clearInterval(interval);
  }, [phase]);

  const startTest = () => {
    if (questions) {
      setAnswers(new Array(questions.length).fill(null));
      setTimeElapsed(0);
      setCurrentQ(0);
      setPhase("test");
    }
  };

  const selectAnswer = (optionIndex: number) => {
    setAnswers((prev) => {
      const next = [...prev];
      next[currentQ] = optionIndex;
      return next;
    });
  };

  const submitTest = useCallback(async () => {
    if (!questions || !user) return;

    const correct = answers.reduce(
      (count, ans, i) => count + (ans === questions[i].correct_answer ? 1 : 0),
      0
    );
    const score = Math.round((correct / questions.length) * 100);

    try {
      await supabase.from("mock_test_results").insert({
        user_id: user.id,
        opportunity_id: opportunityId,
        score,
        total_questions: questions.length,
        correct_answers: correct,
        time_taken_seconds: timeElapsed,
        answers: answers,
      });
      toast.success("Test submitted successfully!");
    } catch (err) {
      console.error(err);
    }

    setPhase("results");
  }, [answers, questions, user, opportunityId, timeElapsed]);

  const formatTime = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m.toString().padStart(2, "0")}:${s.toString().padStart(2, "0")}`;
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="animate-pulse text-muted-foreground">Loading test...</div>
      </div>
    );
  }

  if (!questions || questions.length === 0) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Card className="max-w-md">
          <CardContent className="p-8 text-center">
            <p className="text-muted-foreground mb-4">No questions available for this test.</p>
            <Button onClick={onBack}>Go Back</Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  // INTRO
  if (phase === "intro") {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-4">
        <Card className="max-w-lg w-full">
          <CardContent className="p-8">
            <Button variant="ghost" size="sm" onClick={onBack} className="mb-4 -ml-2">
              <ChevronLeft className="h-4 w-4 mr-1" /> Back
            </Button>
            <h1 className="text-2xl font-bold mb-2">{testInfo?.title || "Mock Test"}</h1>
            <p className="text-muted-foreground mb-6">{testInfo?.short_description}</p>
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div className="bg-muted rounded-lg p-3 text-center">
                <div className="text-xl font-bold text-primary">{questions.length}</div>
                <div className="text-xs text-muted-foreground">Questions</div>
              </div>
              <div className="bg-muted rounded-lg p-3 text-center">
                <div className="text-xl font-bold text-primary">{testInfo?.duration || "60 min"}</div>
                <div className="text-xs text-muted-foreground">Duration</div>
              </div>
            </div>
            <div className="space-y-2 mb-6 text-sm text-muted-foreground">
              <p>• Answer all questions to the best of your ability</p>
              <p>• You can navigate between questions freely</p>
              <p>• Timer will track your total time</p>
              <p>• Results will be shown after submission</p>
            </div>
            <Button onClick={startTest} className="w-full" size="lg">
              Start Test
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  // RESULTS
  if (phase === "results") {
    const correct = answers.reduce(
      (count, ans, i) => count + (ans === questions[i].correct_answer ? 1 : 0),
      0
    );
    const score = Math.round((correct / questions.length) * 100);
    const wrong = questions.length - correct - answers.filter((a) => a === null).length;
    const unanswered = answers.filter((a) => a === null).length;

    return (
      <div className="min-h-screen bg-background p-4">
        <div className="max-w-3xl mx-auto">
          <Button variant="ghost" size="sm" onClick={onBack} className="mb-4">
            <ChevronLeft className="h-4 w-4 mr-1" /> Back to Tests
          </Button>

          {/* Score card */}
          <Card className="mb-6">
            <CardContent className="p-8 text-center">
              <Trophy className={cn("h-16 w-16 mx-auto mb-4", score >= 70 ? "text-yellow-500" : score >= 40 ? "text-primary" : "text-muted-foreground")} />
              <h1 className="text-4xl font-bold mb-2">{score}%</h1>
              <p className="text-muted-foreground mb-6">{testInfo?.title}</p>
              <div className="grid grid-cols-4 gap-4 text-sm">
                <div><div className="text-xl font-bold text-primary">{questions.length}</div><div className="text-muted-foreground">Total</div></div>
                <div><div className="text-xl font-bold text-green-500">{correct}</div><div className="text-muted-foreground">Correct</div></div>
                <div><div className="text-xl font-bold text-destructive">{wrong}</div><div className="text-muted-foreground">Wrong</div></div>
                <div><div className="text-xl font-bold">{formatTime(timeElapsed)}</div><div className="text-muted-foreground">Time</div></div>
              </div>
              <div className="flex gap-3 justify-center mt-6">
                <Button onClick={startTest} variant="outline" className="gap-2">
                  <RotateCcw className="h-4 w-4" /> Retake
                </Button>
                <Button onClick={onBack}>Done</Button>
              </div>
            </CardContent>
          </Card>

          {/* Detailed review */}
          <h2 className="text-lg font-semibold mb-4">Detailed Review</h2>
          <div className="space-y-4">
            {questions.map((q, i) => {
              const userAnswer = answers[i];
              const isCorrect = userAnswer === q.correct_answer;
              return (
                <Card key={q.id} className={cn("border-l-4", isCorrect ? "border-l-green-500" : userAnswer === null ? "border-l-muted" : "border-l-destructive")}>
                  <CardContent className="p-4">
                    <div className="flex items-start gap-3">
                      <div className="shrink-0 mt-0.5">
                        {isCorrect ? (
                          <CheckCircle className="h-5 w-5 text-green-500" />
                        ) : (
                          <XCircle className="h-5 w-5 text-destructive" />
                        )}
                      </div>
                      <div className="flex-1">
                        <p className="font-medium text-sm mb-2">
                          Q{i + 1}. {q.question}
                        </p>
                        <div className="grid gap-1.5 mb-2">
                          {q.options.map((opt: string, oi: number) => (
                            <div
                              key={oi}
                              className={cn(
                                "text-xs px-3 py-1.5 rounded border",
                                oi === q.correct_answer && "bg-green-50 border-green-300 text-green-700 dark:bg-green-900/20 dark:text-green-400",
                                oi === userAnswer && oi !== q.correct_answer && "bg-red-50 border-red-300 text-red-700 dark:bg-red-900/20 dark:text-red-400"
                              )}
                            >
                              {String.fromCharCode(65 + oi)}. {opt}
                            </div>
                          ))}
                        </div>
                        {q.explanation && (
                          <p className="text-xs text-muted-foreground bg-muted rounded p-2">
                            💡 {q.explanation}
                          </p>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>
      </div>
    );
  }

  // TEST PHASE
  const q = questions[currentQ];
  const answered = answers.filter((a) => a !== null).length;
  const progress = (answered / questions.length) * 100;

  return (
    <div className="min-h-screen bg-background">
      {/* Top bar */}
      <div className="sticky top-0 z-50 bg-card border-b px-4 py-3">
        <div className="max-w-3xl mx-auto flex items-center justify-between">
          <h2 className="font-semibold text-sm truncate">{testInfo?.title}</h2>
          <div className="flex items-center gap-4">
            <Badge variant="outline" className="gap-1">
              <Clock className="h-3 w-3" /> {formatTime(timeElapsed)}
            </Badge>
            <span className="text-xs text-muted-foreground">
              {answered}/{questions.length} answered
            </span>
          </div>
        </div>
        <Progress value={progress} className="h-1 mt-2 max-w-3xl mx-auto" />
      </div>

      <div className="max-w-3xl mx-auto p-4">
        {/* Question navigation dots */}
        <div className="flex flex-wrap gap-2 mb-6">
          {questions.map((_, i) => (
            <button
              key={i}
              onClick={() => setCurrentQ(i)}
              className={cn(
                "h-8 w-8 rounded-full text-xs font-medium transition-all",
                currentQ === i && "ring-2 ring-primary",
                answers[i] !== null
                  ? "bg-primary text-primary-foreground"
                  : "bg-muted text-muted-foreground hover:bg-muted/80"
              )}
            >
              {i + 1}
            </button>
          ))}
        </div>

        {/* Question */}
        <Card className="mb-6">
          <CardContent className="p-6">
            <div className="flex items-center gap-2 mb-4">
              <Badge variant="outline" className="text-xs">{q.topic || "General"}</Badge>
              <Badge variant="outline" className={cn("text-xs capitalize",
                q.difficulty === "hard" && "border-destructive text-destructive",
                q.difficulty === "easy" && "border-green-500 text-green-600"
              )}>
                {q.difficulty}
              </Badge>
            </div>
            <h3 className="text-lg font-medium mb-6">
              Q{currentQ + 1}. {q.question}
            </h3>
            <div className="space-y-3">
              {q.options.map((option: string, oi: number) => (
                <button
                  key={oi}
                  onClick={() => selectAnswer(oi)}
                  className={cn(
                    "w-full text-left px-4 py-3 rounded-lg border transition-all text-sm",
                    answers[currentQ] === oi
                      ? "bg-primary/10 border-primary text-primary font-medium"
                      : "hover:bg-muted border-border"
                  )}
                >
                  <span className="font-semibold mr-2">{String.fromCharCode(65 + oi)}.</span>
                  {option}
                </button>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Navigation */}
        <div className="flex items-center justify-between">
          <Button
            variant="outline"
            onClick={() => setCurrentQ(Math.max(0, currentQ - 1))}
            disabled={currentQ === 0}
            className="gap-1"
          >
            <ChevronLeft className="h-4 w-4" /> Previous
          </Button>

          {currentQ === questions.length - 1 ? (
            <Button onClick={submitTest} className="gap-1 bg-green-600 hover:bg-green-700">
              Submit Test <CheckCircle className="h-4 w-4" />
            </Button>
          ) : (
            <Button
              onClick={() => setCurrentQ(Math.min(questions.length - 1, currentQ + 1))}
              className="gap-1"
            >
              Next <ChevronRight className="h-4 w-4" />
            </Button>
          )}
        </div>
      </div>
    </div>
  );
};

export default MockTestTaker;
