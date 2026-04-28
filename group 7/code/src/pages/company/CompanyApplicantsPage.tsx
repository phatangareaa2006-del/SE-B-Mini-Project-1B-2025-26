import { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import {
  Users, Search, ChevronDown, Eye, CheckCircle, XCircle, Clock,
  MessageSquare, Download, Filter, Briefcase, ArrowLeft,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Progress } from "@/components/ui/progress";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter,
} from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { Skeleton } from "@/components/ui/skeleton";
import Navbar from "@/components/layout/Navbar";
import { useAuth } from "@/contexts/AuthContext";
import { apiClient } from "@/api/client";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

const statusColors: Record<string, string> = {
  applied: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
  under_review: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300",
  shortlisted: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300",
  interview: "bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-300",
  offer: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300",
  hired: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300",
  rejected: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300",
};

const statusOptions = [
  { value: "applied", label: "Applied" },
  { value: "under_review", label: "Under Review" },
  { value: "shortlisted", label: "Shortlisted" },
  { value: "interview", label: "Interview" },
  { value: "offer", label: "Offer" },
  { value: "hired", label: "Hired" },
  { value: "rejected", label: "Rejected" },
];

const CompanyApplicantsPage = () => {
  const { user } = useAuth();
  const { jobId } = useParams<{ jobId: string }>();
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [feedbackDialog, setFeedbackDialog] = useState<{ appId: string; name: string } | null>(null);
  const [feedback, setFeedback] = useState("");
  const [updating, setUpdating] = useState<string | null>(null);

  // Fetch company
  const { data: company } = useQuery({
    queryKey: ["my-company", user?.id],
    queryFn: async () => {
      const data = await apiClient.getMyCompany();
      return data;
    },
    enabled: !!user,
  });

  // Fetch jobs for this company
  const { data: jobs } = useQuery({
    queryKey: ["company-jobs", company?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("jobs")
        .select("id, title")
        .eq("company_id", company!.id)
        .order("created_at", { ascending: false });
      if (error) throw error;
      return data;
    },
    enabled: !!company,
  });

  const selectedJobId = jobId || "all";

  // Fetch applicants
  const { data: applicants, isLoading } = useQuery({
    queryKey: ["applicants", company?.id, selectedJobId, statusFilter],
    queryFn: async () => {
      const jobIds = selectedJobId === "all"
        ? jobs?.map((j) => j.id) || []
        : [selectedJobId];

      if (jobIds.length === 0) return [];

      let query = supabase
        .from("applications")
        .select("*, job:jobs(id, title)")
        .in("job_id", jobIds)
        .order("created_at", { ascending: false });

      if (statusFilter !== "all") {
        query = query.eq("status", statusFilter as any);
      }

      const { data, error } = await query;
      if (error) throw error;

      // Fetch profiles for these applicants
      const userIds = data?.map((a) => a.user_id) || [];
      if (userIds.length === 0) return [];

      const { data: profiles } = await supabase
        .from("profiles")
        .select("user_id, full_name, avatar_url, headline, email, resume_url")
        .in("user_id", userIds);

      return data.map((app) => {
        const profile = profiles?.find((p) => p.user_id === app.user_id);
        return {
          ...app,
          profile,
          job: Array.isArray(app.job) ? app.job[0] : app.job,
        };
      });
    },
    enabled: !!company && !!jobs,
  });

  const updateStatus = async (appId: string, newStatus: string) => {
    setUpdating(appId);
    try {
      const { error } = await supabase
        .from("applications")
        .update({ status: newStatus as any })
        .eq("id", appId);
      if (error) throw error;
      toast.success(`Status updated to ${newStatus.replace("_", " ")}`);
      queryClient.invalidateQueries({ queryKey: ["applicants"] });
    } catch (err: any) {
      toast.error("Failed to update status");
    } finally {
      setUpdating(null);
    }
  };

  const submitFeedback = async () => {
    if (!feedbackDialog || !feedback.trim()) return;
    try {
      const { error } = await supabase
        .from("applications")
        .update({ company_feedback: feedback.trim() })
        .eq("id", feedbackDialog.appId);
      if (error) throw error;
      toast.success("Feedback sent");
      setFeedbackDialog(null);
      setFeedback("");
      queryClient.invalidateQueries({ queryKey: ["applicants"] });
    } catch {
      toast.error("Failed to send feedback");
    }
  };

  const filtered = applicants?.filter((a) => {
    if (!searchQuery) return true;
    const name = a.profile?.full_name || "";
    const email = a.profile?.email || "";
    return name.toLowerCase().includes(searchQuery.toLowerCase()) || email.toLowerCase().includes(searchQuery.toLowerCase());
  });

  const getInitials = (name?: string | null) =>
    name ? name.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2) : "U";

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <div className="container mx-auto px-4 py-6">
        <div className="flex items-center gap-3 mb-6">
          <Button asChild variant="ghost" size="icon">
            <Link to="/company/dashboard"><ArrowLeft className="h-5 w-5" /></Link>
          </Button>
          <div>
            <h1 className="text-2xl font-bold">Applicant Tracking</h1>
            <p className="text-muted-foreground">Review and manage all job applications</p>
          </div>
        </div>

        {/* Filters */}
        <Card className="mb-6">
          <CardContent className="p-4">
            <div className="flex flex-col sm:flex-row gap-3">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search by name or email..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-9"
                />
              </div>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Filter by status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Statuses</SelectItem>
                  {statusOptions.map((s) => (
                    <SelectItem key={s.value} value={s.value}>{s.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* Stats */}
        {applicants && (
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-3 mb-6">
            {statusOptions.map((s) => {
              const count = applicants.filter((a) => a.status === s.value).length;
              return (
                <button
                  key={s.value}
                  onClick={() => setStatusFilter(statusFilter === s.value ? "all" : s.value)}
                  className={cn(
                    "rounded-lg p-3 text-center transition-all border",
                    statusFilter === s.value ? "ring-2 ring-primary" : "hover:bg-muted/50"
                  )}
                >
                  <p className="text-2xl font-bold">{count}</p>
                  <p className="text-xs text-muted-foreground capitalize">{s.label}</p>
                </button>
              );
            })}
          </div>
        )}

        {/* Applicant List */}
        {isLoading ? (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => <Skeleton key={i} className="h-24 rounded-xl" />)}
          </div>
        ) : !filtered?.length ? (
          <Card>
            <CardContent className="p-12 text-center">
              <Users className="h-16 w-16 mx-auto text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-1">No applicants found</h3>
              <p className="text-muted-foreground">Applicants will appear here when they apply to your jobs.</p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-3">
            {filtered.map((app) => (
              <Card key={app.id} className="hover:shadow-md transition-shadow">
                <CardContent className="p-4">
                  <div className="flex flex-col sm:flex-row sm:items-center gap-4">
                    <Avatar className="h-12 w-12">
                      <AvatarImage src={app.profile?.avatar_url || undefined} />
                      <AvatarFallback className="bg-primary/10 text-primary">
                        {getInitials(app.profile?.full_name)}
                      </AvatarFallback>
                    </Avatar>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h3 className="font-semibold">{app.profile?.full_name || "Unknown"}</h3>
                        <Badge className={cn("text-xs", statusColors[app.status] || "")}>
                          {app.status.replace("_", " ")}
                        </Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">{app.profile?.email}</p>
                      <div className="flex items-center gap-3 mt-1 text-xs text-muted-foreground">
                        <span className="flex items-center gap-1">
                          <Briefcase className="h-3 w-3" /> {app.job?.title || "Unknown Job"}
                        </span>
                        <span>{new Date(app.created_at).toLocaleDateString("en-IN")}</span>
                        {app.skill_match_percentage !== null && (
                          <span className="flex items-center gap-1">
                            <span className={cn(
                              "font-medium",
                              (app.skill_match_percentage ?? 0) >= 70 ? "text-green-600" : (app.skill_match_percentage ?? 0) >= 40 ? "text-primary" : "text-destructive"
                            )}>
                              {app.skill_match_percentage}% match
                            </span>
                          </span>
                        )}
                      </div>
                    </div>

                    <div className="flex items-center gap-2 flex-wrap">
                      <Select
                        value={app.status}
                        onValueChange={(v) => updateStatus(app.id, v)}
                        disabled={updating === app.id}
                      >
                        <SelectTrigger className="w-[140px] h-9 text-xs">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {statusOptions.map((s) => (
                            <SelectItem key={s.value} value={s.value}>{s.label}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>

                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setFeedbackDialog({ appId: app.id, name: app.profile?.full_name || "Applicant" })}
                      >
                        <MessageSquare className="h-4 w-4" />
                      </Button>

                      {app.profile?.resume_url && (
                        <Button variant="outline" size="sm" asChild>
                          <a href={app.profile.resume_url} target="_blank" rel="noopener">
                            <Download className="h-4 w-4" />
                          </a>
                        </Button>
                      )}
                    </div>
                  </div>

                  {app.company_feedback && (
                    <div className="mt-3 p-3 bg-muted/50 rounded-lg text-sm">
                      <p className="text-xs font-medium text-muted-foreground mb-1">Your Feedback</p>
                      <p>{app.company_feedback}</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* Feedback Dialog */}
      <Dialog open={!!feedbackDialog} onOpenChange={() => setFeedbackDialog(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Send Feedback to {feedbackDialog?.name}</DialogTitle>
            <DialogDescription>This feedback will be visible to the applicant.</DialogDescription>
          </DialogHeader>
          <Textarea
            placeholder="Write your feedback..."
            value={feedback}
            onChange={(e) => setFeedback(e.target.value)}
            className="min-h-[120px]"
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setFeedbackDialog(null)}>Cancel</Button>
            <Button onClick={submitFeedback} disabled={!feedback.trim()}>Send Feedback</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default CompanyApplicantsPage;
