import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import {
  Briefcase,
  Search,
  MapPin,
  Building2,
  IndianRupee,
  Clock,
  Bookmark,
  BookmarkCheck,
  Filter,
  ChevronDown,
  Loader2,
  TrendingUp,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Slider } from "@/components/ui/slider";
import { useAuth } from "@/contexts/AuthContext";
import { apiClient } from "@/api/client";
import Navbar from "@/components/layout/Navbar";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface Job {
  id: string;
  title: string;
  department: string | null;
  job_type: string;
  description: string;
  min_salary: number | null;
  max_salary: number | null;
  locations: string[] | null;
  min_experience: number | null;
  application_deadline: string | null;
  openings: number | null;
  is_remote: boolean | null;
  created_at: string;
  company: {
    id: string;
    name: string;
    logo_url: string | null;
    industry: string | null;
  } | null;
  job_skills: {
    skill: {
      id: string;
      name: string;
    };
    is_required: boolean;
  }[];
}

const JobsPage = () => {
  const { user } = useAuth();
  const [jobs, setJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [savedJobs, setSavedJobs] = useState<Set<string>>(new Set());
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedType, setSelectedType] = useState<string>("all");
  const [selectedLocation, setSelectedLocation] = useState<string>("all");
  const [salaryRange, setSalaryRange] = useState<[number, number]>([0, 100]);
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  const PAGE_SIZE = 10;

  useEffect(() => {
    fetchJobs();
    if (user) {
      fetchSavedJobs();
    }
  }, [user]);

  const fetchJobs = async (reset = true) => {
    try {
      if (reset) {
        setLoading(true);
        setPage(0);
      } else {
        setLoadingMore(true);
      }

      const currentPage = reset ? 0 : page;
      const data = await apiClient.getJobs({ limit: PAGE_SIZE, offset: currentPage * PAGE_SIZE });
      const formattedJobs = Array.isArray(data) ? data : [];

      if (reset) {
        setJobs(formattedJobs);
      } else {
        setJobs((prev) => [...prev, ...formattedJobs]);
      }

      setHasMore(formattedJobs.length === PAGE_SIZE);
      if (!reset) setPage((p) => p + 1);
    } catch (err) {
      console.error("Error fetching jobs:", err);
      toast.error("Failed to load jobs");
    } finally {
      setLoading(false);
      setLoadingMore(false);
    }
  };

  const fetchSavedJobs = async () => {
    try {
      const data = await apiClient.getSavedJobs();
      const jobIds = Array.isArray(data) ? data.map((s: any) => s.job_id || s.id) : [];
      setSavedJobs(new Set(jobIds));
    } catch (err) {
      console.error("Error fetching saved jobs:", err);
    }
  };

  const toggleSaveJob = async (jobId: string) => {
    if (!user) {
      toast.error("Please sign in to save jobs");
      return;
    }

    try {
      if (savedJobs.has(jobId)) {
        await apiClient.unsaveJob(jobId);
        setSavedJobs((prev) => {
          const next = new Set(prev);
          next.delete(jobId);
          return next;
        });
        toast.success("Job removed from saved");
      } else {
        await apiClient.saveJob(jobId);
        setSavedJobs((prev) => new Set([...prev, jobId]));
        toast.success("Job saved successfully");
      }
    } catch (err) {
      console.error("Error toggling save:", err);
      toast.error("Failed to save job");
    }
  };

  const formatSalary = (min: number | null, max: number | null) => {
    if (!min && !max) return "Not disclosed";
    if (min && max) return `₹${(min / 100000).toFixed(1)} - ${(max / 100000).toFixed(1)} LPA`;
    if (min) return `₹${(min / 100000).toFixed(1)}+ LPA`;
    return `Up to ₹${(max! / 100000).toFixed(1)} LPA`;
  };

  const formatDate = (date: string) => {
    const d = new Date(date);
    const now = new Date();
    const diffDays = Math.floor((now.getTime() - d.getTime()) / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return "Today";
    if (diffDays === 1) return "Yesterday";
    if (diffDays < 7) return `${diffDays} days ago`;
    if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks ago`;
    return d.toLocaleDateString("en-IN", { month: "short", day: "numeric" });
  };

  const filteredJobs = jobs.filter((job) => {
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      const matchesTitle = job.title.toLowerCase().includes(query);
      const matchesCompany = job.company?.name.toLowerCase().includes(query);
      const matchesSkills = job.job_skills.some((js) =>
        js.skill?.name.toLowerCase().includes(query)
      );
      if (!matchesTitle && !matchesCompany && !matchesSkills) return false;
    }

    if (selectedType !== "all" && job.job_type !== selectedType) return false;

    return true;
  });

  const JobSkeleton = () => (
    <Card>
      <CardContent className="p-6">
        <div className="flex gap-4">
          <Skeleton className="h-14 w-14 rounded-lg" />
          <div className="flex-1 space-y-3">
            <Skeleton className="h-5 w-3/4" />
            <Skeleton className="h-4 w-1/2" />
            <div className="flex gap-2">
              <Skeleton className="h-6 w-20" />
              <Skeleton className="h-6 w-24" />
              <Skeleton className="h-6 w-16" />
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mx-auto px-4 py-6">
        {/* Search Header */}
        <div className="mb-6">
          <h1 className="text-2xl font-bold font-display mb-4">Find Your Dream Job</h1>
          
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search jobs, companies, or skills..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>

            <Select value={selectedType} onValueChange={setSelectedType}>
              <SelectTrigger className="w-full sm:w-[180px]">
                <SelectValue placeholder="Job Type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="full_time">Full-time</SelectItem>
                <SelectItem value="internship">Internship</SelectItem>
                <SelectItem value="contract">Contract</SelectItem>
                <SelectItem value="part_time">Part-time</SelectItem>
              </SelectContent>
            </Select>

            <Sheet>
              <SheetTrigger asChild>
                <Button variant="outline" className="gap-2">
                  <Filter className="h-4 w-4" />
                  Filters
                </Button>
              </SheetTrigger>
              <SheetContent>
                <SheetHeader>
                  <SheetTitle>Filter Jobs</SheetTitle>
                </SheetHeader>
                <div className="mt-6 space-y-6">
                  <div>
                    <label className="text-sm font-medium mb-3 block">
                      Salary Range (LPA)
                    </label>
                    <Slider
                      value={salaryRange}
                      onValueChange={(v) => setSalaryRange(v as [number, number])}
                      max={100}
                      step={5}
                      className="mb-2"
                    />
                    <div className="flex justify-between text-sm text-muted-foreground">
                      <span>₹{salaryRange[0]} LPA</span>
                      <span>₹{salaryRange[1]} LPA</span>
                    </div>
                  </div>

                  <div>
                    <label className="text-sm font-medium mb-3 block">
                      Location
                    </label>
                    <Select value={selectedLocation} onValueChange={setSelectedLocation}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select location" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Locations</SelectItem>
                        <SelectItem value="bangalore">Bangalore</SelectItem>
                        <SelectItem value="mumbai">Mumbai</SelectItem>
                        <SelectItem value="delhi">Delhi NCR</SelectItem>
                        <SelectItem value="hyderabad">Hyderabad</SelectItem>
                        <SelectItem value="pune">Pune</SelectItem>
                        <SelectItem value="chennai">Chennai</SelectItem>
                        <SelectItem value="remote">Remote</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <Button className="w-full" onClick={() => fetchJobs(true)}>
                    Apply Filters
                  </Button>
                </div>
              </SheetContent>
            </Sheet>
          </div>
        </div>

        {/* Results Count */}
        <div className="mb-4 text-sm text-muted-foreground">
          {loading ? (
            <Skeleton className="h-4 w-32" />
          ) : (
            `Showing ${filteredJobs.length} jobs`
          )}
        </div>

        {/* Job List */}
        <div className="space-y-4">
          {loading ? (
            Array.from({ length: 5 }).map((_, i) => <JobSkeleton key={i} />)
          ) : filteredJobs.length === 0 ? (
            <Card>
              <CardContent className="py-12 text-center">
                <Briefcase className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <h3 className="font-semibold mb-2">No jobs found</h3>
                <p className="text-muted-foreground text-sm">
                  Try adjusting your search or filters
                </p>
              </CardContent>
            </Card>
          ) : (
            filteredJobs.map((job) => (
              <Card key={job.id} className="card-hover">
                <CardContent className="p-6">
                  <div className="flex gap-4">
                    {/* Company Logo */}
                    <div className="h-14 w-14 rounded-lg bg-muted flex items-center justify-center shrink-0">
                      {job.company?.logo_url ? (
                        <img
                          src={job.company.logo_url}
                          alt={job.company.name}
                          className="h-12 w-12 rounded object-contain"
                        />
                      ) : (
                        <Building2 className="h-6 w-6 text-muted-foreground" />
                      )}
                    </div>

                    {/* Job Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <div>
                          <Link
                            to={`/jobs/${job.id}`}
                            className="font-semibold hover:text-primary transition-colors line-clamp-1"
                          >
                            {job.title}
                          </Link>
                          <p className="text-sm text-muted-foreground">
                            {job.company?.name || "Company"}
                            {job.company?.industry && ` • ${job.company.industry}`}
                          </p>
                        </div>

                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => toggleSaveJob(job.id)}
                          className="shrink-0"
                        >
                          {savedJobs.has(job.id) ? (
                            <BookmarkCheck className="h-5 w-5 text-primary" />
                          ) : (
                            <Bookmark className="h-5 w-5" />
                          )}
                        </Button>
                      </div>

                      {/* Meta Info */}
                      <div className="flex flex-wrap gap-2 mt-3">
                        <Badge variant="secondary" className="gap-1">
                          <MapPin className="h-3 w-3" />
                          {job.locations?.[0] || "Remote"}
                          {job.is_remote && " (Remote)"}
                        </Badge>
                        <Badge variant="secondary" className="gap-1">
                          <IndianRupee className="h-3 w-3" />
                          {formatSalary(job.min_salary, job.max_salary)}
                        </Badge>
                        <Badge variant="secondary" className="gap-1 capitalize">
                          <Briefcase className="h-3 w-3" />
                          {job.job_type.replace("_", "-")}
                        </Badge>
                        <Badge variant="outline" className="gap-1">
                          <Clock className="h-3 w-3" />
                          {formatDate(job.created_at)}
                        </Badge>
                      </div>

                      {/* Skills */}
                      {job.job_skills.length > 0 && (
                        <div className="flex flex-wrap gap-1.5 mt-3">
                          {job.job_skills.slice(0, 5).map((js) => (
                            <Badge
                              key={js.skill?.id}
                              variant={js.is_required ? "default" : "outline"}
                              className="text-xs"
                            >
                              {js.skill?.name}
                            </Badge>
                          ))}
                          {job.job_skills.length > 5 && (
                            <Badge variant="outline" className="text-xs">
                              +{job.job_skills.length - 5} more
                            </Badge>
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))
          )}

          {/* Load More */}
          {!loading && hasMore && filteredJobs.length > 0 && (
            <div className="flex justify-center pt-4">
              <Button
                variant="outline"
                onClick={() => fetchJobs(false)}
                disabled={loadingMore}
                className="gap-2"
              >
                {loadingMore ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <ChevronDown className="h-4 w-4" />
                )}
                Load More Jobs
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default JobsPage;
