import { useState } from "react";
import { Link } from "react-router-dom";
import { FileText, Clock, Users, ChevronLeft, ChevronRight, Trophy } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import Navbar from "@/components/layout/Navbar";
import Sidebar from "@/components/home/Sidebar";
import { useAuth } from "@/contexts/AuthContext";
import { cn } from "@/lib/utils";
import { Skeleton } from "@/components/ui/skeleton";
import MockTestTaker from "@/components/mocktest/MockTestTaker";

const MockTestsPage = () => {
  const { user } = useAuth();
  const [sidebarCollapsed] = useState(false);
  const [activeTestId, setActiveTestId] = useState<string | null>(null);

  const { data: tests, isLoading } = useQuery({
    queryKey: ["mock-tests"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("opportunities")
        .select("*")
        .eq("opportunity_type", "mock_test")
        .eq("is_active", true)
        .order("created_at", { ascending: false });
      if (error) throw error;
      return data;
    },
  });

  const { data: questionCounts } = useQuery({
    queryKey: ["mock-test-question-counts"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("mock_test_questions")
        .select("opportunity_id");
      if (error) throw error;
      const counts: Record<string, number> = {};
      data?.forEach((q) => {
        counts[q.opportunity_id!] = (counts[q.opportunity_id!] || 0) + 1;
      });
      return counts;
    },
  });

  const { data: pastResults } = useQuery({
    queryKey: ["mock-test-results", user?.id],
    queryFn: async () => {
      if (!user) return [];
      const { data, error } = await supabase
        .from("mock_test_results")
        .select("*")
        .eq("user_id", user.id)
        .order("completed_at", { ascending: false });
      if (error) throw error;
      return data;
    },
    enabled: !!user,
  });

  if (activeTestId) {
    return (
      <MockTestTaker
        opportunityId={activeTestId}
        onBack={() => setActiveTestId(null)}
      />
    );
  }

  const getBestScore = (testId: string) => {
    const results = pastResults?.filter((r) => r.opportunity_id === testId);
    if (!results || results.length === 0) return null;
    return Math.max(...results.map((r) => r.score));
  };

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <Sidebar isCollapsed={sidebarCollapsed} />

      <main className={cn("transition-all duration-300 pt-16", "lg:ml-64", sidebarCollapsed && "lg:ml-16")}>
        <div className="border-b bg-card px-4 lg:px-6 py-6">
          <div className="max-w-4xl mx-auto">
            <Link to="/" className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-4">
              <ChevronLeft className="h-4 w-4" /> Back to Home
            </Link>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-primary/10 flex items-center justify-center">
                <FileText className="h-5 w-5 text-primary" />
              </div>
              <div>
                <h1 className="text-2xl lg:text-3xl font-bold">Mock Tests</h1>
                <p className="text-muted-foreground">Practice with timed tests for placements and competitive exams</p>
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 lg:px-6 py-8 max-w-4xl mx-auto">
          {/* Past results summary */}
          {pastResults && pastResults.length > 0 && (
            <Card className="mb-8 bg-primary/5 border-primary/20">
              <CardContent className="p-6">
                <div className="flex items-center gap-3 mb-4">
                  <Trophy className="h-5 w-5 text-primary" />
                  <h2 className="font-semibold">Your Test History</h2>
                </div>
                <div className="grid grid-cols-3 gap-4 text-center">
                  <div>
                    <div className="text-2xl font-bold text-primary">{pastResults.length}</div>
                    <div className="text-xs text-muted-foreground">Tests Taken</div>
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-primary">
                      {pastResults.length > 0
                        ? Math.round(pastResults.reduce((a, r) => a + r.score, 0) / pastResults.length)
                        : 0}%
                    </div>
                    <div className="text-xs text-muted-foreground">Avg Score</div>
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-primary">
                      {pastResults.length > 0 ? Math.max(...pastResults.map((r) => r.score)) : 0}%
                    </div>
                    <div className="text-xs text-muted-foreground">Best Score</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {isLoading ? (
            <div className="grid gap-4">
              {[1, 2, 3].map((i) => (
                <Skeleton key={i} className="h-40 rounded-xl" />
              ))}
            </div>
          ) : tests && tests.length > 0 ? (
            <div className="grid gap-4">
              {tests.map((test) => {
                const qCount = questionCounts?.[test.id] || 0;
                const bestScore = getBestScore(test.id);
                return (
                  <Card key={test.id} className="card-hover">
                    <CardContent className="p-6">
                      <div className="flex flex-col sm:flex-row sm:items-center gap-4">
                        <div className="flex-1">
                          <div className="flex items-center gap-2 mb-2">
                            <h3 className="font-semibold text-lg">{test.title}</h3>
                            {test.is_featured && (
                              <Badge className="bg-primary/10 text-primary text-xs">Featured</Badge>
                            )}
                          </div>
                          <p className="text-sm text-muted-foreground mb-3">{test.short_description}</p>
                          <div className="flex flex-wrap gap-3 text-xs text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <FileText className="h-3.5 w-3.5" /> {qCount} Questions
                            </span>
                            <span className="flex items-center gap-1">
                              <Clock className="h-3.5 w-3.5" /> {test.duration || "60 min"}
                            </span>
                            {test.tags?.map((tag) => (
                              <Badge key={tag} variant="outline" className="text-xs">{tag}</Badge>
                            ))}
                          </div>
                          {bestScore !== null && (
                            <div className="mt-2">
                              <Badge variant="secondary" className="text-xs">Best Score: {bestScore}%</Badge>
                            </div>
                          )}
                        </div>
                        <Button
                          onClick={() => setActiveTestId(test.id)}
                          disabled={qCount === 0}
                          className="gap-2 whitespace-nowrap"
                        >
                          {bestScore !== null ? "Retake Test" : "Start Test"}
                          <ChevronRight className="h-4 w-4" />
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          ) : (
            <div className="text-center py-20">
              <FileText className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
              <h2 className="text-xl font-bold mb-2">No mock tests available</h2>
              <p className="text-muted-foreground">Check back later for new tests!</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default MockTestsPage;
