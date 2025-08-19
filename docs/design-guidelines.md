# Piano Fitness Design Guidelines

## Overview

Piano Fitness provides a visually engaging, modern, and motivating experience for piano learners. The design aesthetic draws heavily from the Repertoire page feature, which exemplifies our commitment to clarity, beauty, responsive design, and comprehensive accessibility.

## Design Philosophy

The Repertoire page represents our design system's core values: clean gradients, intuitive interaction patterns, responsive layouts that adapt to any screen size, and thoughtful accessibility implementations. Every component should feel polished, purposeful, and inspiring to use.

## Visual Aesthetic

### Color System

**Primary Palette:**

- **Indigo**: `#6366F1` - Primary brand color for headers, buttons, and key interactive elements
- **Purple**: `#8B5CF6` - Secondary accent for gradients and visual interest
- **Orange**: `#F59E0B` - Accent color for highlights, recommendations, and guidance text
- **Green**: `#10B981` - Success states, active timers, and positive feedback
- **Amber**: `#FFC107` - Warning states, paused timers, and attention-drawing elements

**Supporting Colors:**

- **Blue**: `#3B82F6` - Information containers and secondary actions
- **White**: `#FFFFFF` - Primary background and container fills
- **Gray**: `#F8FAFC` - Subtle backgrounds and inactive states

**Gradient Implementations:**

- Primary gradient: Indigo to Purple (`#6366F1` → `#8B5CF6`)
- Success gradient: Green tones for active states
- Subtle gradients at 5-10% opacity for container backgrounds

### Typography Hierarchy

**Font Weights & Sizing:**

- **Headers**: Bold (FontWeight.bold), 16-20px with -0.3 letter spacing
- **Subheaders**: Semi-bold (FontWeight.w600), 14-16px with -0.1 letter spacing
- **Body Text**: Regular (FontWeight.normal), 12-15px with standard spacing
- **Status Text**: Semi-bold (FontWeight.w600), 10-13px for timer status
- **Guidance Text**: Italic for instructional content in orange tones

### Component Design Language

**Container Styling:**

- **Border Radius**: 16-20px for main containers, 12-16px for nested elements
- **Borders**: 1-2px solid with 10-30% opacity of the primary color
- **Shadows**: Subtle depth with 5-10% opacity, 4-12px blur radius
- **Background**: White with optional subtle gradients

**Interactive Elements:**

- **Buttons**: Circular for actions, rounded rectangles for selections
- **Elevation**: 1-4px for depth hierarchy
- **Gradients**: Used for primary actions and selected states
- **Touch Targets**: Platform standards take precedence (44x44pt for iOS, 48x48dp for Android). For web accessibility, use a minimum of 44x44px

**Iconography:**

- **Style**: Material Design icons with color accents
- **Sizing**: 14-24px responsive to screen constraints
- **Colors**: Match the primary color system
- **Usage**: Consistent icons for similar actions across features

## Responsive Design Patterns

### Layout Modes

Based on the Repertoire page's responsive layout system:

**Mobile Portrait** (width < 768px, height > width):

- Vertical stacking of components
- Compact spacing (6-8px)
- Smaller font sizes and touch targets

**Mobile Landscape** (width < 768px, width > height):

- Horizontal layouts where space permits
- Optimized button spacing (12-16px)
- Efficient use of available width

**Tablet Portrait** (width ≥ 768px, height > width):

- Generous spacing (16-24px)
- Larger typography and touch targets
- Expanded container padding

**Tablet Landscape** (width ≥ 768px, width > height):

- Side-by-side component layouts
- Maximum spacing (24-32px)
- Optimal use of horizontal space

### Adaptive Component Behavior

- **Dynamic sizing**: Components scale based on available space
- **Flexible layouts**: Graceful degradation for constrained spaces
- **Content prioritization**: Critical elements remain visible
- **Touch optimization**: Larger targets on touch devices

## Accessibility Guidelines

### Semantic Structure

**Screen Reader Support:**

- All interactive elements must have semantic labels
- Use `Semantics` widgets with descriptive `label` properties
- Implement `button: true` for actionable elements
- Include context in labels (e.g., "15 minutes, recommended")

**Live Regions:**

- Timer displays use `liveRegion: true` for real-time updates
- Status changes announced via `SemanticsService.announce()`
- Progress updates communicated to assistive technologies

### Visual Accessibility

**Color Contrast:**

- Minimum 4.5:1 contrast ratio for normal text
- Minimum 3:1 contrast ratio for large text
- Color never used as the sole indicator of meaning
- High contrast maintained across all color combinations

**Typography Accessibility:**

- Scalable font sizes that respect system settings
- Clear font weights for proper hierarchy
- Adequate line spacing (1.2-1.4 line height)
- Letter spacing optimizations for readability

### Interaction Accessibility

**Touch Targets:**

- Minimum 44x44pt touch targets (iOS) / 48x48dp (Android)
- Adequate spacing between interactive elements
- Clear focus indicators for keyboard navigation
- Consistent interaction patterns across the app

**Motor Accessibility:**

- Generous spacing between controls (12-20px minimum)
- Large button sizes in landscape orientations
- Scroll areas when content exceeds viewport
- Forgiving touch areas with proper padding

### Cognitive Accessibility

**Clear Mental Models:**

- Consistent iconography and color coding
- Predictable navigation patterns
- Clear status indicators and feedback
- Contextual help and guidance

**Information Architecture:**

- Logical grouping of related controls
- Progressive disclosure of complex features
- Clear visual hierarchy with proper contrast
- Descriptive error messages and guidance

## Component Specifications

### Timer Display

- **Circular progress indicator** with gradient color coding
- **Status badges** with icon + text for current state
- **Control buttons** with semantic labels and announcements
- **Responsive sizing** from 30px (constrained) to 70px (expanded)

### Duration Selector

- **Wrapped button layout** with proper spacing
- **Selected state** indicated by gradient and elevation
- **Recommended option** marked with star icon and border
- **Semantic announcements** for selection changes

### Modal Dialogs

- **Draggable bottom sheets** with rounded top corners
- **Scrollable content** with proper padding
- **App recommendation cards** with clear CTAs
- **Close affordance** with accessible labeling

### Container Cards

- **Gradient backgrounds** at low opacity (5-10%)
- **Border styling** with color-matched outlines
- **Shadow depth** for visual hierarchy
- **Responsive padding** (8-16px based on screen size)

## Interaction Patterns

### Timer Controls

- **Start/Resume**: Green gradient button with play icon
- **Pause**: Amber gradient button with pause icon  
- **Reset**: Outlined button with refresh icon
- **Visual feedback**: Color changes and semantic announcements

### Navigation

- **Bottom navigation**: Consistent with app-wide patterns
- **Modal presentation**: Bottom sheets for supplementary content
- **App integration**: External link handling with proper feedback

### Responsive Behavior

- **Layout switching**: Automatic adaptation based on constraints
- **Content prioritization**: Essential elements remain accessible
- **Graceful degradation**: Functional in minimal space

## Implementation Guidelines

### Code Structure

- **Responsive utilities**: Use `LayoutBuilder` for constraint-based layouts
- **Semantic widgets**: Implement `Semantics` for all interactive elements
- **State announcements**: Use `SemanticsService.announce()` for dynamic changes
- **Flexible sizing**: Implement adaptive sizing based on available space

### Testing Requirements

- **Accessibility testing**: VoiceOver/TalkBack verification
- **Responsive testing**: Multiple screen sizes and orientations
- **Color contrast validation**: Automated and manual testing
- **Touch target verification**: Minimum size compliance

### Performance Considerations

- **Efficient layouts**: Minimize rebuilds with proper state management
- **Asset optimization**: Appropriate image sizing and caching
- **Animation performance**: Smooth transitions without jank
- **Memory usage**: Proper disposal of resources

## Conclusion

The Piano Fitness design system, exemplified by the Repertoire page, creates an inclusive, beautiful, and highly functional user experience. Every design decision should prioritize user accessibility, responsive adaptation, and motivational aesthetics to help users achieve their musical goals.

These guidelines ensure consistency across features while maintaining the flexibility to innovate within our established design language.
