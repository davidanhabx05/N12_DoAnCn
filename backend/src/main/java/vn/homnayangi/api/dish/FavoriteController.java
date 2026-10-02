package vn.homnayangi.api.dish;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import vn.homnayangi.api.auth.AuthContext;
import vn.homnayangi.api.dish.UserDishRepository.Kind;

/** Món đã thích và món đã lưu của người dùng đang đăng nhập. */
@RestController
@RequestMapping("/api/me")
public class FavoriteController {

    private final DishService service;

    public FavoriteController(DishService service) {
        this.service = service;
    }

    @GetMapping("/likes")
    public List<DishDto> likes() {
        return service.list(Kind.LIKE, AuthContext.requireUserId());
    }

    @PostMapping("/likes/{dishId}")
    public DishService.LikeResult like(@PathVariable long dishId) {
        return service.setLiked(AuthContext.requireUserId(), dishId, true);
    }

    @DeleteMapping("/likes/{dishId}")
    public DishService.LikeResult unlike(@PathVariable long dishId) {
        return service.setLiked(AuthContext.requireUserId(), dishId, false);
    }

    @GetMapping("/bookmarks")
    public List<DishDto> bookmarks() {
        return service.list(Kind.BOOKMARK, AuthContext.requireUserId());
    }

    /** Chỉ danh sách id món đã lưu (nhẹ, dùng khi mở app). */
    @GetMapping("/bookmarks/ids")
    public List<String> bookmarkIds() {
        return service.ids(Kind.BOOKMARK, AuthContext.requireUserId());
    }

    @PostMapping("/bookmarks/{dishId}")
    public DishService.BookmarkResult bookmark(@PathVariable long dishId) {
        return service.setBookmarked(AuthContext.requireUserId(), dishId, true);
    }

    @DeleteMapping("/bookmarks/{dishId}")
    public DishService.BookmarkResult unbookmark(@PathVariable long dishId) {
        return service.setBookmarked(AuthContext.requireUserId(), dishId, false);
    }
}
