import { useState } from "react";
import { Link } from "react-router-dom";
import { 
  Briefcase, 
  Users, 
  Building2, 
  GraduationCap, 
  ChevronRight, 
  Sparkles, 
  TrendingUp, 
  Globe,
  Menu
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import Navbar from "@/components/layout/Navbar";
import Sidebar from "@/components/home/Sidebar";
import HeroSection from "@/components/home/HeroSection";
import CategorySection from "@/components/home/CategorySection";
import SearchBar from "@/components/home/SearchBar";
import FeaturedCarousel from "@/components/home/FeaturedCarousel";
import { useFeaturedOpportunities, useOpportunitiesByType } from "@/hooks/useOpportunities";
import { useAuth } from "@/contexts/AuthContext";
import { cn } from "@/lib/utils";

const Index = () => {
  const { user, role } = useAuth();
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [showMobileSidebar, setShowMobileSidebar] = useState(false);

  // Fetch opportunities
  const { data: featuredOpportunities, isLoading: loadingFeatured } = useFeaturedOpportunities();
  const { data: internships, isLoading: loadingInternships } = useOpportunitiesByType("internship", 10);
  const { data: jobs, isLoading: loadingJobs } = useOpportunitiesByType("job", 10);
  const { data: mockTests, isLoading: loadingMockTests } = useOpportunitiesByType("mock_test", 10);

  const handleSearch = (query: string) => {
    // TODO: Navigate to search results page
    console.log("Searching:", query);
  };

  // Landing page for non-authenticated users
  if (!user) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />

        {/* Hero Section */}
        <section className="relative overflow-hidden">
          <div className="absolute inset-0 gradient-hero opacity-10" />
          <div className="container mx-auto px-4 py-20 lg:py-32 relative">
            <div className="max-w-4xl mx-auto text-center">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 text-primary text-sm font-medium mb-6">
                <Sparkles className="h-4 w-4" />
                AI-Powered Campus Recruitment Platform
              </div>
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold font-display mb-6">
                Your Gateway to{" "}
                <span className="gradient-text">Career Success</span>
              </h1>
              <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
                Connect with top companies, discover opportunities, and land your
                dream job through India's most intelligent placement platform.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" asChild className="h-12 px-8">
                  <Link to="/auth?tab=signup">
                    Get Started Free
                    <ChevronRight className="ml-2 h-5 w-5" />
                  </Link>
                </Button>
                <Button size="lg" variant="outline" asChild className="h-12 px-8">
                  <Link to="/auth">Sign In</Link>
                </Button>
              </div>
            </div>
          </div>
        </section>

        {/* Stats Section */}
        <section className="border-y bg-card">
          <div className="container mx-auto px-4 py-12">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
              <div>
                <div className="text-3xl lg:text-4xl font-bold text-primary mb-2">500+</div>
                <div className="text-muted-foreground">Partner Colleges</div>
              </div>
              <div>
                <div className="text-3xl lg:text-4xl font-bold text-primary mb-2">1000+</div>
                <div className="text-muted-foreground">Hiring Companies</div>
              </div>
              <div>
                <div className="text-3xl lg:text-4xl font-bold text-primary mb-2">50K+</div>
                <div className="text-muted-foreground">Students Placed</div>
              </div>
              <div>
                <div className="text-3xl lg:text-4xl font-bold text-primary mb-2">₹12 LPA</div>
                <div className="text-muted-foreground">Avg. Package</div>
              </div>
            </div>
          </div>
        </section>

        {/* Features Section */}
        <section className="py-20">
          <div className="container mx-auto px-4">
            <div className="text-center mb-16">
              <h2 className="text-3xl lg:text-4xl font-bold font-display mb-4">
                Everything You Need to Succeed
              </h2>
              <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
                From resume building to interview preparation, we've got you covered.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              <Card className="card-hover">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                    <GraduationCap className="h-6 w-6 text-primary" />
                  </div>
                  <CardTitle>For Students</CardTitle>
                  <CardDescription>
                    Build your professional profile, get AI-powered job recommendations,
                    and track your applications in one place.
                  </CardDescription>
                </CardHeader>
              </Card>

              <Card className="card-hover">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                    <Building2 className="h-6 w-6 text-primary" />
                  </div>
                  <CardTitle>For Companies</CardTitle>
                  <CardDescription>
                    Post jobs, manage applicants with Kanban boards, and find the
                    perfect candidates with smart matching.
                  </CardDescription>
                </CardHeader>
              </Card>

              <Card className="card-hover">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                    <Globe className="h-6 w-6 text-primary" />
                  </div>
                  <CardTitle>For Colleges</CardTitle>
                  <CardDescription>
                    Manage student placements, track analytics, and build
                    relationships with recruiting companies.
                  </CardDescription>
                </CardHeader>
              </Card>

              <Card className="card-hover">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                    <Sparkles className="h-6 w-6 text-primary" />
                  </div>
                  <CardTitle>AI Resume Parser</CardTitle>
                  <CardDescription>
                    Upload your resume and let our AI automatically extract your
                    skills, experience, and education.
                  </CardDescription>
                </CardHeader>
              </Card>

              <Card className="card-hover">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                    <TrendingUp className="h-6 w-6 text-primary" />
                  </div>
                  <CardTitle>Smart Matching</CardTitle>
                  <CardDescription>
                    Our algorithm matches your skills with job requirements,
                    showing you the best-fit opportunities first.
                  </CardDescription>
                </CardHeader>
              </Card>

              <Card className="card-hover">
                <CardHeader>
                  <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                    <Users className="h-6 w-6 text-primary" />
                  </div>
                  <CardTitle>Professional Network</CardTitle>
                  <CardDescription>
                    Connect with peers, alumni, and recruiters. Build your network
                    and discover new opportunities.
                  </CardDescription>
                </CardHeader>
              </Card>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-20 gradient-hero text-primary-foreground">
          <div className="container mx-auto px-4 text-center">
            <h2 className="text-3xl lg:text-4xl font-bold font-display mb-4">
              Ready to Start Your Journey?
            </h2>
            <p className="text-xl opacity-90 mb-8 max-w-2xl mx-auto">
              Join thousands of students who have found their dream jobs through PlacementHub.
            </p>
            <Button size="lg" variant="secondary" asChild className="h-12 px-8">
              <Link to="/auth?tab=signup">
                Create Free Account
                <ChevronRight className="ml-2 h-5 w-5" />
              </Link>
            </Button>
          </div>
        </section>

        {/* Footer */}
        <footer className="border-t py-12">
          <div className="container mx-auto px-4">
            <div className="flex flex-col md:flex-row justify-between items-center gap-4">
              <div className="flex items-center gap-2">
                <div className="h-8 w-8 rounded-lg gradient-bg flex items-center justify-center">
                  <Briefcase className="h-4 w-4 text-primary-foreground" />
                </div>
                <span className="font-bold font-display">PlacementHub</span>
              </div>
              <p className="text-sm text-muted-foreground">
                © 2026 PlacementHub. All rights reserved.
              </p>
            </div>
          </div>
        </footer>
      </div>
    );
  }

  // Logged-in user dashboard (Unstop-style)
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      
      {/* Mobile menu button */}
      <Button
        variant="ghost"
        size="icon"
        className="fixed bottom-4 left-4 z-50 lg:hidden rounded-full shadow-lg bg-primary text-primary-foreground hover:bg-primary/90"
        onClick={() => setShowMobileSidebar(!showMobileSidebar)}
      >
        <Menu className="h-5 w-5" />
      </Button>

      {/* Sidebar - hidden on mobile by default */}
      <div className={cn(
        "hidden lg:block",
        showMobileSidebar && "block"
      )}>
        <Sidebar isCollapsed={sidebarCollapsed} onToggle={() => setSidebarCollapsed(!sidebarCollapsed)} />
      </div>
      
      {/* Mobile sidebar overlay */}
      {showMobileSidebar && (
        <div 
          className="fixed inset-0 bg-background/80 backdrop-blur-sm z-30 lg:hidden"
          onClick={() => setShowMobileSidebar(false)}
        />
      )}
      
      {/* Main content */}
      <main 
        className={cn(
          "transition-all duration-300 pt-16",
          "lg:ml-64",
          sidebarCollapsed && "lg:ml-16"
        )}
      >
        {/* Top bar with search and business button */}
        <div className="sticky top-16 z-30 bg-background/95 backdrop-blur-sm border-b border-border/50 px-4 lg:px-6 py-4">
          <div className="flex items-center gap-4 max-w-7xl mx-auto">
            <SearchBar onSearch={handleSearch} className="flex-1" />
            <Link to={role === "company" ? "/company/dashboard" : "/auth?tab=signup"}>
              <Button variant="outline" className="gap-2 whitespace-nowrap rounded-full hidden sm:flex">
                <Building2 className="h-4 w-4" />
                For Business
              </Button>
            </Link>
          </div>
        </div>

        {/* Content area */}
        <div className="px-4 lg:px-6 py-8 max-w-7xl mx-auto space-y-12">
          {/* Hero section */}
          <HeroSection talentCount="28Mn+" />

          {/* Category cards */}
          <CategorySection />

          {/* Featured opportunities */}
          <FeaturedCarousel 
            opportunities={featuredOpportunities || []} 
            title="Featured" 
            isLoading={loadingFeatured}
          />

          {/* Internships section */}
          <FeaturedCarousel 
            opportunities={internships || []} 
            title="Internships" 
            isLoading={loadingInternships}
          />

          {/* Jobs section */}
          <FeaturedCarousel 
            opportunities={jobs || []} 
            title="Jobs" 
            isLoading={loadingJobs}
          />

          {/* Empty state when no opportunities */}
          {!loadingFeatured && !featuredOpportunities?.length && 
           !loadingInternships && !internships?.length &&
           !loadingJobs && !jobs?.length && (
            <div className="text-center py-20">
              <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-primary/10 mb-6">
                <Building2 className="h-10 w-10 text-primary" />
              </div>
              <h2 className="text-2xl font-bold mb-2">No opportunities yet</h2>
              <p className="text-muted-foreground mb-6 max-w-md mx-auto">
                Be the first to post opportunities! Companies can register and start posting internships, jobs, and competitions.
              </p>
              <Link to="/auth?tab=signup">
                <Button size="lg" className="gap-2">
                  <Building2 className="h-4 w-4" />
                  Register as a Company
                </Button>
              </Link>
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default Index;
