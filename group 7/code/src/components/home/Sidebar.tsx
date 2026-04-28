import { Link, useLocation } from "react-router-dom";
import {
  Home,
  Briefcase,
  Trophy,
  FileText,
  GraduationCap,
  Users,
  MessageSquare,
  Bell,
  Settings,
  Code,
  Bookmark,
  User,
  Plus,
  Building2,
  UserCircle,
  Award,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/contexts/AuthContext";
import { Separator } from "@/components/ui/separator";
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface SidebarProps {
  isCollapsed?: boolean;
  onToggle?: () => void;
}

const Sidebar = ({ isCollapsed = false }: SidebarProps) => {
  const location = useLocation();
  const { user, role } = useAuth();

  const mainNavItems = [
    { icon: Home, label: "Home", href: "/" },
    { icon: Briefcase, label: "Jobs", href: "/jobs" },
    { icon: Briefcase, label: "Internships", href: "/internships" },
    { icon: FileText, label: "Mock Tests", href: "/mock-tests" },
    { icon: GraduationCap, label: "Mentorships", href: "/mentorships" },
  ];

  const socialNavItems = [
    { icon: Users, label: "Network", href: "/network" },
    { icon: MessageSquare, label: "Messages", href: "/messages" },
    { icon: Bell, label: "Notifications", href: "/notifications" },
  ];

  const userNavItems = [
    { icon: User, label: "My Profile", href: "/profile" },
    { icon: Bookmark, label: "Saved", href: "/saved" },
    { icon: FileText, label: "Applications", href: "/applications" },
    { icon: Award, label: "Certificates", href: "/certificates" },
  ];

  const companyNavItems = [
    { icon: Building2, label: "Dashboard", href: "/company/dashboard" },
    { icon: Briefcase, label: "Post Job", href: "/company/post-job" },
    { icon: Users, label: "Applicants", href: "/company/applicants" },
  ];

  const NavItem = ({ icon: Icon, label, href }: { icon: any; label: string; href: string }) => {
    const isActive = location.pathname === href;
    
    const content = (
      <Link
        to={href}
        className={cn(
          "flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200",
          "hover:bg-primary/10 hover:text-primary",
          isActive && "bg-primary/10 text-primary font-medium",
          !isActive && "text-muted-foreground",
          isCollapsed && "justify-center px-2"
        )}
      >
        <Icon className="h-5 w-5 shrink-0" />
        {!isCollapsed && <span className="truncate">{label}</span>}
      </Link>
    );

    if (isCollapsed) {
      return (
        <Tooltip delayDuration={0}>
          <TooltipTrigger asChild>{content}</TooltipTrigger>
          <TooltipContent side="right" className="font-medium">
            {label}
          </TooltipContent>
        </Tooltip>
      );
    }

    return content;
  };

  return (
    <aside
      className={cn(
        "fixed left-0 top-16 h-[calc(100vh-4rem)] bg-background border-r border-border",
        "hidden md:flex flex-col py-4 transition-all duration-300 z-40",
        isCollapsed ? "w-16" : "w-64",
        "overflow-y-auto scrollbar-hide"
      )}
    >
      {/* Create button */}
      {user && (
        <div className="px-3 mb-4">
          <Button
            className={cn(
              "w-full gap-2 rounded-xl bg-gradient-to-r from-primary to-primary/80",
              isCollapsed && "px-0"
            )}
          >
            <Plus className="h-4 w-4" />
            {!isCollapsed && "Create"}
          </Button>
        </div>
      )}

      {/* Main navigation */}
      <nav className="px-2 space-y-1">
        {mainNavItems.map((item) => (
          <NavItem key={item.href} {...item} />
        ))}
      </nav>

      <Separator className="my-4 mx-3" />

      {/* Social navigation */}
      <nav className="px-2 space-y-1">
        {socialNavItems.map((item) => (
          <NavItem key={item.href} {...item} />
        ))}
      </nav>

      {user && (
        <>
          <Separator className="my-4 mx-3" />

          {/* User navigation */}
          <nav className="px-2 space-y-1">
            {role === "company" ? (
              companyNavItems.map((item) => (
                <NavItem key={item.href} {...item} />
              ))
            ) : (
              userNavItems.map((item) => (
                <NavItem key={item.href} {...item} />
              ))
            )}
          </nav>
        </>
      )}

      {/* Bottom section */}
      <div className="mt-auto px-2 pt-4">
        <Separator className="mb-4 mx-1" />
        <NavItem icon={Settings} label="Settings" href="/settings" />
      </div>
    </aside>
  );
};

export default Sidebar;
