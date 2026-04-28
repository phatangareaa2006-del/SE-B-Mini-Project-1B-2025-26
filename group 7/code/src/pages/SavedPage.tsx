import { useState } from "react";
import { Link } from "react-router-dom";
import { Bookmark, ChevronLeft, Heart, Trash2 } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import Navbar from "@/components/layout/Navbar";
import Sidebar from "@/components/home/Sidebar";
import OpportunityCard from "@/components/home/OpportunityCard";
import { useAuth } from "@/contexts/AuthContext";
import { cn } from "@/lib/utils";
import { Skeleton } from "@/components/ui/skeleton";

const SavedPage = () => {
  const { user } = useAuth();
  const [sidebarCollapsed] = useState(false);

  const { data: savedOpportunities, isLoading, refetch } = useQuery({
    queryKey: ["saved-opportunities", user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      const { data, error } = await supabase
        .from("saved_opportunities")
        .select(`
          id,
          opportunity_id,
          opportunities (*)
        `)
        .eq("user_id", user.id)
        .order("created_at", { ascending: false });

      if (error) throw error;
      return data?.map(item => item.opportunities).filter(Boolean) || [];
    },
    enabled: !!user,
  });

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <Sidebar isCollapsed={sidebarCollapsed} />
      
      <main className={cn(
        "transition-all duration-300 pt-16",
        "lg:ml-64",
        sidebarCollapsed && "lg:ml-16"
      )}>
        {/* Header */}
        <div className="border-b bg-card px-4 lg:px-6 py-6">
          <div className="max-w-7xl mx-auto">
            <Link 
              to="/" 
              className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-4"
            >
              <ChevronLeft className="h-4 w-4" />
              Back to Home
            </Link>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-primary/10 flex items-center justify-center">
                <Bookmark className="h-5 w-5 text-primary" />
              </div>
              <div>
                <h1 className="text-2xl lg:text-3xl font-bold">Saved Opportunities</h1>
                <p className="text-muted-foreground">
                  {savedOpportunities?.length || 0} saved items
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="px-4 lg:px-6 py-8 max-w-7xl mx-auto">
          {isLoading ? (
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {[1, 2, 3, 4].map((i) => (
                <Skeleton key={i} className="h-[380px] rounded-xl" />
              ))}
            </div>
          ) : savedOpportunities && savedOpportunities.length > 0 ? (
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {savedOpportunities.map((opportunity: any) => (
                <OpportunityCard
                  key={opportunity.id}
                  id={opportunity.id}
                  title={opportunity.title}
                  organizerName={opportunity.organizer_name}
                  organizerLogo={opportunity.organizer_logo}
                  imageUrl={opportunity.image_url}
                  mode={opportunity.mode}
                  isFree={opportunity.is_free}
                  location={opportunity.location}
                  startDate={opportunity.start_date}
                  endDate={opportunity.end_date}
                  registrationDeadline={opportunity.registration_deadline}
                  prizePool={opportunity.prize_pool}
                  stipendMin={opportunity.stipend_min}
                  stipendMax={opportunity.stipend_max}
                  tags={opportunity.tags}
                  currentParticipants={opportunity.current_participants}
                  opportunityType={opportunity.opportunity_type}
                  isSaved={true}
                  onSaveToggle={() => refetch()}
                />
              ))}
            </div>
          ) : (
            <div className="text-center py-20">
              <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-primary/10 mb-6">
                <Heart className="h-10 w-10 text-primary" />
              </div>
              <h2 className="text-2xl font-bold mb-2">No saved opportunities</h2>
              <p className="text-muted-foreground mb-6 max-w-md mx-auto">
                Start saving opportunities you're interested in by clicking the heart icon on any listing.
              </p>
              <Button asChild>
                <Link to="/">Explore Opportunities</Link>
              </Button>
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default SavedPage;
