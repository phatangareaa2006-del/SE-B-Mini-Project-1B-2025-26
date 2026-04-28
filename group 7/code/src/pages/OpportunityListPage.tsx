import { useState } from "react";
import { Link } from "react-router-dom";
import { Briefcase, Search, Filter, MapPin, Building2, ChevronLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import Navbar from "@/components/layout/Navbar";
import Sidebar from "@/components/home/Sidebar";
import OpportunityCard from "@/components/home/OpportunityCard";
import { useOpportunitiesByType, OpportunityType } from "@/hooks/useOpportunities";
import { cn } from "@/lib/utils";
import { Skeleton } from "@/components/ui/skeleton";

interface OpportunityListPageProps {
  type: OpportunityType;
  title: string;
  description: string;
}

const OpportunityListPage = ({ type, title, description }: OpportunityListPageProps) => {
  const [searchQuery, setSearchQuery] = useState("");
  const [modeFilter, setModeFilter] = useState<string>("all");
  const [priceFilter, setPriceFilter] = useState<string>("all");
  const [sidebarCollapsed] = useState(false);

  const { data: opportunities, isLoading } = useOpportunitiesByType(type, 50);

  // Filter opportunities based on search and filters
  const filteredOpportunities = opportunities?.filter((opp) => {
    const matchesSearch = opp.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      opp.organizer_name?.toLowerCase().includes(searchQuery.toLowerCase());
    
    const matchesMode = modeFilter === "all" || opp.mode === modeFilter;
    const matchesPrice = priceFilter === "all" || 
      (priceFilter === "free" && opp.is_free) ||
      (priceFilter === "paid" && !opp.is_free);

    return matchesSearch && matchesMode && matchesPrice;
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
            <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
              <div>
                <h1 className="text-2xl lg:text-3xl font-bold flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-primary/10 flex items-center justify-center">
                    <Briefcase className="h-5 w-5 text-primary" />
                  </div>
                  {title}
                </h1>
                <p className="text-muted-foreground mt-1">{description}</p>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground">
                  {filteredOpportunities?.length || 0} opportunities
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="sticky top-16 z-20 bg-background/95 backdrop-blur-sm border-b px-4 lg:px-6 py-4">
          <div className="max-w-7xl mx-auto flex flex-wrap gap-4">
            <div className="relative flex-1 min-w-[200px]">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder={`Search ${title.toLowerCase()}...`}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9"
              />
            </div>
            <Select value={modeFilter} onValueChange={setModeFilter}>
              <SelectTrigger className="w-[140px]">
                <SelectValue placeholder="Mode" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Modes</SelectItem>
                <SelectItem value="online">Online</SelectItem>
                <SelectItem value="offline">Offline</SelectItem>
                <SelectItem value="hybrid">Hybrid</SelectItem>
                <SelectItem value="wfh">Work from Home</SelectItem>
              </SelectContent>
            </Select>
            <Select value={priceFilter} onValueChange={setPriceFilter}>
              <SelectTrigger className="w-[140px]">
                <SelectValue placeholder="Price" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All</SelectItem>
                <SelectItem value="free">Free</SelectItem>
                <SelectItem value="paid">Paid</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Content */}
        <div className="px-4 lg:px-6 py-8 max-w-7xl mx-auto">
          {isLoading ? (
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
                <Skeleton key={i} className="h-[380px] rounded-xl" />
              ))}
            </div>
          ) : filteredOpportunities && filteredOpportunities.length > 0 ? (
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {filteredOpportunities.map((opportunity) => (
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
                />
              ))}
            </div>
          ) : (
            <div className="text-center py-20">
              <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-primary/10 mb-6">
                <Briefcase className="h-10 w-10 text-primary" />
              </div>
              <h2 className="text-2xl font-bold mb-2">No {title.toLowerCase()} found</h2>
              <p className="text-muted-foreground mb-6 max-w-md mx-auto">
                {searchQuery 
                  ? `No results for "${searchQuery}". Try a different search term.`
                  : `There are no ${title.toLowerCase()} available at the moment. Check back later!`
                }
              </p>
              {searchQuery && (
                <Button variant="outline" onClick={() => setSearchQuery("")}>
                  Clear Search
                </Button>
              )}
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default OpportunityListPage;
