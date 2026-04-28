import { useQuery } from "@tanstack/react-query";
import { apiClient } from "@/api/client";

export type OpportunityType = "internship" | "job" | "competition" | "mock_test" | "mentorship" | "course";

interface UseOpportunitiesOptions {
  type?: OpportunityType;
  featured?: boolean;
  limit?: number;
  search?: string;
}

export const useOpportunities = (options: UseOpportunitiesOptions = {}) => {
  const { type, featured, limit = 20, search } = options;

  return useQuery({
    queryKey: ["opportunities", { type, featured, limit, search }],
    queryFn: async () => {
      const opportunities = await apiClient.getOpportunities();
      
      let filtered = opportunities || [];
      
      if (type) {
        filtered = filtered.filter((opp: any) => opp.opportunity_type === type);
      }

      if (featured) {
        filtered = filtered.filter((opp: any) => opp.is_featured === true);
      }

      if (search) {
        const searchLower = search.toLowerCase();
        filtered = filtered.filter((opp: any) => 
          opp.title?.toLowerCase().includes(searchLower) || 
          opp.description?.toLowerCase().includes(searchLower)
        );
      }

      if (limit) {
        filtered = filtered.slice(0, limit);
      }

      return filtered;
    },
  });
};

export const useFeaturedOpportunities = () => {
  return useOpportunities({ featured: true, limit: 10 });
};

export const useOpportunitiesByType = (type: OpportunityType, limit = 20) => {
  return useOpportunities({ type, limit });
};
