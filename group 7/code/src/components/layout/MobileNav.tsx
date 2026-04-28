import { Link, useLocation } from "react-router-dom";
import { Home, Briefcase, Users, MessageSquare, Bell, Building2, LayoutDashboard } from "lucide-react";
import { cn } from "@/lib/utils";
import { useAuth } from "@/contexts/AuthContext";
import { useQuery } from "@tanstack/react-query";

const MobileNav = () => {
  const location = useLocation();
  const { user, role } = useAuth();

  const { data: unreadCount } = useQuery({
    queryKey: ["unread-notifications-count", user?.id],
    queryFn: async () => {
      if (!user) return 0;
      const { count, error } = await supabase
        .from("notifications")
        .select("*", { count: "exact", head: true })
        .eq("user_id", user.id)
        .eq("is_read", false);
      if (error) return 0;
      return count || 0;
    },
    enabled: !!user,
    refetchInterval: 10000,
  });

  const { data: unreadMsgCount } = useQuery({
    queryKey: ["unread-messages-count", user?.id],
    queryFn: async () => {
      if (!user) return 0;
      const { count, error } = await supabase
        .from("messages")
        .select("*", { count: "exact", head: true })
        .eq("receiver_id", user.id)
        .eq("is_read", false);
      if (error) return 0;
      return count || 0;
    },
    enabled: !!user,
    refetchInterval: 10000,
  });

  if (!user) return null;

  const studentItems = [
    { icon: Home, label: "Home", href: "/" },
    { icon: Briefcase, label: "Jobs", href: "/jobs" },
    { icon: Users, label: "Network", href: "/network" },
    { icon: MessageSquare, label: "Messages", href: "/messages", badge: unreadMsgCount },
    { icon: Bell, label: "Alerts", href: "/notifications", badge: unreadCount },
  ];

  const companyItems = [
    { icon: LayoutDashboard, label: "Dashboard", href: "/company/dashboard" },
    { icon: Briefcase, label: "Post Job", href: "/company/post-job" },
    { icon: Users, label: "Applicants", href: "/company/applicants" },
    { icon: MessageSquare, label: "Messages", href: "/messages", badge: unreadMsgCount },
    { icon: Bell, label: "Alerts", href: "/notifications", badge: unreadCount },
  ];

  const items = role === "company" ? companyItems : studentItems;

  return (
    <nav className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-background border-t safe-area-bottom">
      <div className="flex items-center justify-around h-14">
        {items.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.href;
          return (
            <Link
              key={item.href}
              to={item.href}
              className={cn(
                "flex flex-col items-center gap-0.5 px-2 py-1 relative transition-colors",
                isActive ? "text-primary" : "text-muted-foreground"
              )}
            >
              <div className="relative">
                <Icon className="h-5 w-5" />
                {item.badge && item.badge > 0 && (
                  <span className="absolute -top-1.5 -right-2 h-4 min-w-[16px] px-1 rounded-full bg-destructive text-destructive-foreground text-[9px] flex items-center justify-center font-medium">
                    {item.badge > 99 ? "99+" : item.badge}
                  </span>
                )}
              </div>
              <span className="text-[10px] font-medium">{item.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
};

export default MobileNav;
