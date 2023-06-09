### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ e93c5882-1ef8-43f6-b1ee-ee23c813c91b
begin
	# import Pkg
	# Pkg.add("Contour")
	# Pkg.activate(mktempdir())
	# Pkg.add([
	# 	Pkg.PackageSpec(name="ImageIO", version="0.5"),
	# 	Pkg.PackageSpec(name="ImageShow", version="0.3"),
	# 	Pkg.PackageSpec(name="FileIO", version="1.9"),
	# 	Pkg.PackageSpec(name="CommonMark", version="0.8"),
	# 	Pkg.PackageSpec(name="Plots", version="1.16"),
	# 	Pkg.PackageSpec(name="PlotThemes", version="2.0"),
	# 	Pkg.PackageSpec(name="LaTeXStrings", version="1.2"),
	# 	Pkg.PackageSpec(name="PlutoUI", version="0.7"),
	# 	Pkg.PackageSpec(name="Pluto", version="0.14"),
	# 	Pkg.PackageSpec(name="SymPy", version="1.0"),
	#   	Pkg.PackageSpec(name="HypertextLiteral", version="0.7"),
	# 	Pkg.PackageSpec(name="ImageTransformations", version="0.8")
	# ])

	
	using CommonMark, ImageIO, FileIO, ImageShow
	using PlutoUI
	using Plots, PlotThemes, LaTeXStrings, Random
	using SymPy
	using HypertextLiteral
	using ImageTransformations
	using Contour
	using Dates
end

# ╔═╡ 0c3da8f0-7138-4521-ac5b-362a36380a8c
cm"""
<script src="//unpkg.com/alpinejs" defer></script>
"""

# ╔═╡ 014747b8-d1be-414b-adcb-1bc6971b84be
@htl("""
<style>
.img-container {
	display:flex;
	align-items:center;
	flex-direction: column;
}
blockquote {
  background: #0e08bf;
  border-left: 10px solid #0e08bf;
  margin: 1.5em 10px;
}
blockquote:before {
  color: #0e08bf;
  content: open-quote;
  font-size: 3em;
  line-height: 0.1em;
  margin-right: 0.25em;
  vertical-align: -0.4em;
}
blockquote:after {
  color: transparent;
  content: close-quote;
}
blockquote p {
  display: inline;
}
blockquote > ol {
  list-style: none;
  counter-reset: steps;
}
blockquote > ol li {
  counter-increment: steps;
}
blockquote > ol li::before {
  content: counter(steps);
  margin-right: 0.5rem;
  margin-top: 0.5rem;
  background: #ff6f00;
  color: white;
  width: 1.2em;
  height: 1.2em;
  border-radius: 50%;
  display: inline-grid;
  place-items: center;
  line-height: 1.2em;
}
blockquote > ol ol li::before {
  background: darkorchid;
}
</style>
""")

# ╔═╡ ad045108-9dca-4a61-ac88-80a3417c95f2
TableOfContents(title="MATH102 - TERM 222")

# ╔═╡ 1e9f4829-1f50-47ae-8745-0daa90e7aa42
md""" # Chapter 7

## Section 7.1
### Area of a Region Between Two Curves

> __Objectives__
> - Find the area of a region between two curves using integration.
> - Find the area of a region between intersecting curves using integration.
> - Describe integration as an accumulation process.

"""

# ╔═╡ 90f42d35-f81e-4c38-8a73-77b37755f671
begin 
	struct PlotData
		x::StepRangeLen
		fun::Function
		lb::Union{Integer,Vector{Float64}}
	end
	PlotData(x,f)=PlotData(x,f,0)	
	@recipe function f(t::PlotData; customcolor = :green, fillit=true)
		x, fun, lb = t.x, t.fun, t.lb
		xrotation --> 45
		zrotation --> 6, :quiet
		aspect_ratio --> 1
		framestyle --> :origin
		label-->nothing
		fill --> (fillit ? (lb,0.5,customcolor) : nothing)
		x, fun.(x)
	end
	x, y = symbols("x,y", real=true)
	p1Opt = (framestyle=:origin, aspectration=1)
	function plot_implicit(F, c=0;
			xrng=(-5,5), yrng=xrng, zrng=xrng,
			nlevels=6,         # number of levels in a direction
			slices=Dict(:x => :blue,
				:y => :red,
				:z => :green), # which directions and color
			kwargs...          # passed to initial `plot` call
		)

		_linspace(rng, n=150) = range(rng[1], stop=rng[2], length=n)

		X1, Y1, Z1 = _linspace(xrng), _linspace(yrng), _linspace(zrng)

		p = Plots.plot(;legend=false,kwargs...)

		if :x ∈ keys(slices)
			for x in _linspace(xrng, nlevels)
				local X1 = [F(x,y,z) for y in Y1, z in Z1]
				cnt = contours(Y1,Z1,X1, [c])
				for line in lines(levels(cnt)[1])
					ys, zs = coordinates(line) # coordinates of this line segment
					plot!(p, x .+ 0 * ys, ys, zs, color=slices[:x])
				end
			end
		end

		if :y ∈ keys(slices)
			for y in _linspace(yrng, nlevels)
				local Y1 = [F(x,y,z) for x in X1, z in Z1]
				cnt = contours(Z1,X1,Y1, [c])
				for line in lines(levels(cnt)[1])
					xs, zs = coordinates(line) # coordinates of this line segment
					plot!(p, xs, y .+ 0 * xs, zs, color=slices[:y])
				end
			end
		end

		if :z ∈ keys(slices)
			for z in _linspace(zrng, nlevels)
				local Z1 = [F(x, y, z) for x in X1, y in Y1]
				cnt = contours(X1, Y1, Z1, [c])
				for line in lines(levels(cnt)[1])
					xs, ys = coordinates(line) # coordinates of this line segment
					plot!(p, xs, ys, z .+ 0 * xs, color=slices[:z])
				end
			end
		end


		p
	end
	html"......"
end

# ╔═╡ aac97852-3abc-4455-80fe-a61aec320d24
begin
	cnstSlider = @bind cnstslider Slider(-2:1:2, default=0)
	n1Slider = @bind n1slider Slider(1:200, default=1,show_value=true)
	md"""
	| | |
	|---|---|
	|move $cnstSlider| ``n`` = $n1Slider|
	|||
	"""
end

# ╔═╡ e427ab16-9d5a-4200-8d96-8e49ec0da312
begin
	f1(x) = sin(x)+3+cnstslider
	f2(x) = cos(2x)+1+cnstslider
	f3(x) = cos(2x)+4+cnstslider
	poi1=solve(f1(x)-f3(x),x) .|> p -> p.n()
	theme(:wong)
	a1,b1 = 1, 5
	Δx1 = (b1-a1)/n1slider
	x1Rect =a1:Δx1:b1
	x1 = a1:0.1:b1
	y1 = f1.(x1)
	y2 = f2.(x1)
	y3 = f3.(x1)
	
	p1=plot(x1,y1, fill=(y2,0.25,:green), label=nothing,c=:red)
	p2=plot(x1,y1, fill=(y3,0.25,:green), label=nothing,c=:red)
	
	plot!(p1,x1,y2,label=nothing)
	plot!(p2,x1,y3,label=nothing)
	annotate!(p1,[
				(3.5,3.5+cnstslider,L"y=f(x)",:red),
				(5.9,0,L"x"),
				(0.2,6,L"y"),
				(3.2,1+cnstslider,L"y=g(x)",:blue)
				]
			)
	annotate!(p2,[
				(1.2,4.5+cnstslider,L"y=f(x)",:red),
				(5.9,0,L"x"),
				(0.2,6,L"y"),
				(4,5+cnstslider,L"y=g(x)",:blue)
				]
			)
	
	plot!(p1; p1Opt...,ylims=(-3,6),xlims=(-1,6))
	recs =[
			Shape([(xi,f2(xi)),(xi+Δx1,f2(xi)),(xi+Δx1,f1(xi+Δx1)),(xi,f1(xi+Δx1))]) 			 for xi in x1Rect[1:end-1]
		  ]
	n1slider>2 && plot!(p1,recs, label=nothing,c=:green)
	plot!(p2; p1Opt...,ylims=(-3,6),xlims=(-1,6))
	scatter!(p2,(poi1[1],f3(poi1[1])), label="Point of instersection",legend=:bottomright)
	# save("./imgs/6.1/sec6.1p2.png",p2)
	# annotate!(p2,[(4,0.51,(L"$\sum_{i=1}^{%$n2} f (x^*_{i})\Delta x=%$s2$",12))])
	
	md""" **How can we find the area between the two curves?**
	
$p1
	
```math
Area = \int_a^b \left[{\color{red}f(x)} - {\color{blue}g(x)}\right] dx
```
"""

end

# ╔═╡ 2ddde4c4-8217-41e3-9235-a6370b11ae5c
md"""

**Remark**
- Area = ``y_{top}-y_{bottom}``.

**Example 1**

Find the area of the region bounded above by $y=e^x$, bounded below by $y=x$, bounded on the sides by $x=0$ and $x=1$.

---
"""

# ╔═╡ 07dee140-2553-4b2e-bd28-1dda978fb34c
begin
	ex1x=0:0.01:1
	ex1y=exp.(ex1x)
	ex1plt=plot(ex1x,ex1y,label=nothing,fill=(0,0.5,:red))
	plot!(ex1plt,ex1x,ex1x,fill=(0,0,:white),label=nothing)
	plot!(;p1Opt...,xlims=(-0.4,1.5),ylims=(-0.4,3.5),label=nothing,xticks=[0,0,1])
	ex1Rect = Shape([(0.5,0.55),(0.55,0.55),(0.55,exp(0.55)),(0.5,exp(0.55))])
	plot!(ex1Rect,label=nothing)
	annotate!([	(0.77,0.6,L"y=x")
			  ,	(0.7,exp(0.7)+0.2,L"y=e^x")
			  , (1.1,1.7,L"x=1")
			  , (-0.1,0.5,L"x=0")
			  , (0.54,0.44,text(L"\Delta x",10))
			  ])
	md"""
	**Solution**
	$ex1plt
	"""
end

# ╔═╡ d7928de3-89a4-4475-ba5b-2e707084685b
md"""
### Area of a Region Between Intersecting Curves
In geberal,

$p2
	
```math
Area = \int_a^b \left|f(x) - g(x)\right| dx
```

"""

# ╔═╡ 784142ee-1416-4ccb-a341-0497422009b6
html"<hr>"

# ╔═╡ a65d268a-cb45-4d6c-ac77-ac719010cfb3
md"""
**Example 2**

Find the area of the region enclosed by the parabolas $y=x^2$ and $y=2x-x^2$.

*Solution in class*

---
"""


# ╔═╡ 6a4dd437-8be1-4e17-b484-65707ec28215
begin
	ex2f1(x)=x^2
	ex2f2(x)=2x-x^2
	ex2poi=solve(ex2f1(x)-ex2f2(x)) .|> p->p.n()
	ex2x=0:0.01:1
	ex2widex=-1:0.01:2
	ex2y1=ex2f1.(ex2x)
	ex2y1wide=ex2f1.(ex2widex)
	ex2y2=ex2f2.(ex2x)
	ex2y2wide=ex2f2.(ex2widex)
	ex2plt=plot(ex2x,ex2y2,label=nothing,fill=(0,0.5,:green))
	plot!(ex2plt,ex2x,ex2y1,fill=(0,0,:white),label=nothing)
	plot!(ex2widex,ex2y1wide, c=:red,label=nothing)
	plot!(ex2widex,ex2y2wide, c=:blue,label=nothing)
	plot!(;p1Opt...,xlims=(-0.4,1.5),ylims=(-0.4,2),label=nothing,xticks=[0,0,1])
	ex2Rect = Shape([ (0.5,ex2f2(0.55))
					, (0.55,ex2f2(0.55))
					, (0.55,ex2f1(0.55))
					, (0.5,ex2f1(0.55))
					])
	plot!(ex2Rect,label=nothing)
	scatter!(ex2poi,ex2f1.(ex2poi),label=nothing)
	annotate!([	(0.77,0.4,L"y=x^2")
			  ,	(0.7,1.1,L"y=2x-x^2")
			  , (0.54,0.24,text(L"\Delta x",10))
			  ])
	md"""
	**Solution**
	
	$ex2plt
	"""
end

# ╔═╡ 4337bc1f-933f-4e8d-abae-46b8ad99409e
md"""
**Example 3**

Find the area of the region bounded by the curves 

```math 
y=\cos(x), \;\; y=\sin(2x), \;\; x=0, \;\; x=\frac{\pi}{2}
```


---
"""

# ╔═╡ 539cbac4-c1be-4f9d-b076-215c4430a3a6
begin
	ex3f1(x) = cos(x)
	ex3f2(x) = sin(2x)
	ex3X=0:0.01:(π+0.019)/2
	
	ex3Y1=ex3f1.(ex3X)
	ex3Y2=ex3f2.(ex3X)
	ex3P = plot(ex3X,ex3Y1,label=L"y=\cos(x)", c=:red)
	plot!(ex3P,ex3X,ex3Y1,fill=(ex3Y2,0.25,:green),label=nothing,c=nothing)
	plot!(ex3P,ex3X,ex3Y2,label=L"y=\sin(2x)",c=:blue)
	plot!(ex3P;p1Opt...,xlims=(-1,π),ylims=(-1.1,1.1))
	scatter!(ex3P,(π/6,ex3f1(π/6)),label=nothing,c=:black)
	
	md"""
	**Solution**
	
	$ex3P
	"""
end

# ╔═╡ 1006936d-e13e-4146-b0ac-905acb1f7d08
begin
	img1 = load(download("https://www.dropbox.com/s/r39ny15umqafmls/wrty.png?raw=1"))
	img1 = imresize(img1,ratio=1.5)
	md"""
	### Integrating with Respect to ``y``
	
	$img1
	
	"""
	
end

# ╔═╡ 64f36566-5747-4c8f-b90f-1ced674365cb
md"""
**Example 4**

Find the area enclosed by the line ``y=x-1``  and the parabola ``y^2=2x+6``.

"""

# ╔═╡ 61b6234e-5cb2-4337-ae29-14106ac6bd59
begin
	ex4FRight(y)=-3+y^2/2
	ex4FLeft(y)=y+1
	ex4p = plot(x->x^2/2 -3,x->x,-5,6,c=:blue,label=L"y^2=2x+6")
	ex4Rect = Shape([ (ex4FRight(1.8),2)
					, (ex4FLeft(2),2)
					, (ex4FLeft(2),1.8)
					, (ex4FRight(1.8),1.8)
					])
	plot!(ex4Rect,label=nothing)
	plot!(ex4p,x->x,x->x-1,-5,6;p1Opt...,c=:red,label=L"y=x-1",xticks=-3:1:15)
	(ex4poi1,ex4poi2)=solve([y^2-2*x-6,y-x+1],[x,y]) 
	scatter!([ex4poi1,ex4poi2],xlims=(-3.5,7),label=nothing,legend=:topleft)
	md"""
	**Solution:**
	$ex4p
	"""
end

# ╔═╡ 237a0543-7d70-48ff-a8b5-37bb31dd98d8


# ╔═╡ e370f794-41b6-4acf-9ef6-453fba223dea
# integrate(y+1-(y^2/2-3),(y,-2,4))

# ╔═╡ 629f1cf7-ffa9-496b-9a3f-405089b43a8e
md"""
**Example 5**

Find the area of the region enclosed by the curves ``y= {1\over x}``, ``y=x``, and ``y={1\over 4} x``, using
* ``x`` as the variable of integration and
* ``y`` as the variable of integration.


"""

# ╔═╡ 0b4677a8-93e3-4fc9-91e8-8a7e77d18e2b
begin
	x5=0.1:0.1:10
	x51=0:0.1:1
	p5 = plot(x->x/4, xlims=(-1,10), framestyle=:origin, aspectratio=1,label=nothing)
	plot!(x->x,c=:red,label=nothing)
	# plot!(x51,1 ./ x51,fill=(x51/4,0.5,:blue),c=:white)
	plot!(x5,1 ./ x5,c=:green,label=nothing)
	xlims!(-0.1,3)
	ylims!(-0.1,2)
end

# ╔═╡ 598b7b2e-01dd-41aa-966a-a361921a5c60
cm"""
## Section 7.2
### Volume: The Disk Method
> __Objectives__
> - Find the volume of a solid of revolution using the disk method.
> - Find the volume of a solid of revolution using the washer method.
> - Find the volume of a solid with known cross sections.

**Solids of Revolution**

<div class="img-container">

$(Resource("https://www.dropbox.com/s/z2k777veuxiaorq/solids_of_revs.png?raw=1"))
</div>


<div class="img-container">

$(Resource("https://www.dropbox.com/s/ik73cokibh1fuj6/disk_volume.png?raw=1"))

__Volume of a disk__
```math
V = \pi R^2 w
```
</div>

<div class="img-container">

__Disk Method__

$(Resource("https://www.dropbox.com/s/odttq795nrpcznw/disk_method.png?raw=1"))
</div>

```math
\begin{array}{lcl}
\textrm{Volume of solid} & \approx &\displaystyle \sum_{i=1}^n\pi\bigl[R(x_i)\bigr]^2 \Delta x \\
	& = &\displaystyle \pi\sum_{i=1}^n\bigl[R(x_i)\bigr]^2 \Delta x
\end{array}
```
Taking the limit ``\|\Delta\|\to 0 (n\to \infty)``, we get


```math
\begin{array}{lcl}
\textrm{Volume of solid} & = &\displaystyle\lim_{\|\Delta\|\to 0}\pi \sum_{i=1}^n\bigl[R(x_i)\bigr]^2 \Delta x \end{array} = \pi \int_{a}^{b}\bigl[R(x)\bigr]^2 dx.
```

<div class="img-container">

__Disk Method__

__To find the volume of a solid of revolution with the disk method, use one of the formulas below__

$(Resource("https://www.dropbox.com/s/9kpj2dcrwj5y5h8/disk_volume_v_h.png?raw=1"))
</div>

"""

# **Volumes**

# Let's start with a simple solid **`cylinders`**

# $(Resource("https://www.dropbox.com/s/mofqdenjokjci44/img1.png?raw=1"))

# ### Cross-Section Method
# $(Resource("https://www.dropbox.com/s/xz80mrwj2fserd5/img2.png?raw=1"))

# Let's now try to find a formula for finding the volume of this solid

# $(Resource("https://www.dropbox.com/s/uvz7my3n08fgm6w/img3.png?raw=1"))

# ╔═╡ ffcdd27d-0974-4071-9543-8474a02f09e8
cm"""
__Example 1:__
Find the volume of the solid formed by revolving the region bounded by the graph of
```math
f(x) = \sqrt{\sin x}
```
and the ``x``-axis (``0\leq x\leq \pi``) about the ``x``-axis
"""

# ╔═╡ e7a8a1e7-b4c5-4d33-8e2d-e4fd6b15e89b
cm"""
__Example 2__:
Find the volume of the solid formed by revolving the region bounded by the graphs of
```math
f(x)=2-x^2
```
and ``g(x)=1``  about the line ``y=1``.
"""

# ╔═╡ 35c589c5-8206-4cd5-b4e6-cc5758d17cf6
cm"""
### The Washer Method

<div class="img-container">

$(Resource("https://www.dropbox.com/s/ajra8g5fr8ssewe/washer_volume.png?raw=1"))

```math
\textrm{Volume of washer} = \pi(R^2-r^2)w
```
</div>

__Washer Method__


<div class="img-container">

$(Resource("https://www.dropbox.com/s/hvwa3707bftjir0/washer_method.png?raw=1"))

```math
V = \pi\int_a^b \bigl[\left(R[x]\right)^2-\left(r[x]\right)^2) dx
```
</div>
"""

# ╔═╡ bc3988a9-048c-4bbf-8197-edcea8898818
cm"""
__Example 3__ Find the volume of the solid formed by revolving the region bounded by the graphs of
```math
y=\sqrt{x} \qquad \textrm{and}\qquad  y = x^2
```
about the ``x``-axis.

"""

# ╔═╡ dad5ee5f-b2f4-4582-b2ef-855e7b9dc49b
cm"""
__Example 4__ Find the volume of the solid formed by revolving the region bounded by the graphs of
```math
y=x^2+1, \quad y=0, \quad x=0, \quad \textrm{and}\quad x=1
```
about the ``y``-axis
"""

# ╔═╡ 02fd559e-2a51-4a15-af4e-bd50149cb0e8
cm"""
### Solids with Known Cross Sections

[Example 1](https://www.geogebra.org/m/XFgMaKTy) | [Example 2](https://www.geogebra.org/m/XArpgR3A)

1. For cross sections of area ``A(x)`` taken perpendicular to the ``x``-axis,
```math
V = \int_a^b A(x) dx
```
2. For cross sections of area ``A(y)`` taken perpendicular to the ``y``-axis,
```math
V = \int_c^d A(y) dy
```

__Example 6__ 
The base of a solid is the region bounded by the lines
```math
f(x)=1-\frac{x}{2},\quad g(x)=-1+\frac{x}{2}\quad \textrm{and}\quad x=0.
```
The cross sections perpendicular to the ``x``-axis are equilateral triangles.
"""

# ╔═╡ 5c1989f5-bd7b-4c82-a9e3-54f47539fe2d
# md"""
# * Let’s divide ``S`` into ``n`` “slabs” of equal width ``\Delta x`` by using the planes``P_{x_1},P_{x_2},\cdots`` to slice the solid. (*Think of slicing a loaf of bread.*) 
# * If we choose sample points ``x_i^*`` in ``[x_{i-1},x_i]`` , we can approximate the ``i``th slab ``S_i`` by a cylinder with base area ``A(x_i^*)`` and height ``\Delta x``.

# ```math
# V(S_i) \approx A(x_i^*)\Delta x
# ```

# So, we have

# ```math
# V \approx \sum_{i=1}^{n} A(x_i^*)\Delta x
# ```
# #### Definition of Volume
# Let ``S`` be a solid that lies between ``x=a`` and ``x=b``. If the cross-sectional area of ``S`` in the plane ``P_x`` , through ``x`` and perpendicular to the ``x``-axis, is ``A(x)`` , where ``A`` is a continuous function, then the **volume** of ``S``  is 
# ```math
# V = \lim_{n\to\infty} \sum_{i=1}^{n} A(x_i^*)\Delta x = \int_{a}^{b}A(x) dx
# ```
# """

# ╔═╡ 078023da-23bc-4401-a1dc-fe869400f9b0
# md"""
# ### Volumes of Solids of Revolution
# If we revolve a region about a line, we obtain a **solid of revolution**. In the following examples we see that for such a solid, cross-sections perpendicular to the axis of rotation are **circular**.

# **Example 1**
# Find the volume of the solid obtained by rotating about the ``x``-axis the region under the curve ``y=\sqrt{x}`` from ``0`` to ``1`` . Illustrate the definition of volume by sketching a typical approximating cylinder.
# """

# ╔═╡ 440eec5a-5a9b-4783-9dd2-3427fe340bc6
# begin
# 	fun(x)=sqrt(x)
# 	s6e1 = PlotData(0:0.01:1, fun)	
# 	tt=range(0.1,stop=1,length=100) |> collect
# 	ss=range(0.1,stop=1,length=100) |> collect
# 	y_grid = [x for x=ss for y=tt]
# 	z_grid = [y for x=ss for y=tt]
# 	f(x, z) = begin
#          x ^ 2 + z ^2
#     end
# 	p3 =plot(	
# 				plot(s6e1; customcolor = :black )
# 			,	plot_implicit((x,y,z)->y^2+z^2-x,xrng=(-2,2),yrng=(-1,1),zrng=(-1,2),
#    nlevels=200, slices=Dict(:x=>:red),aspect_ratio=1,frame_style=:origin)
# 			)
# 	md"""
# 	**Solution**

# 	$p3

# 	"""
# end

# ╔═╡ 835bf3cc-eca3-4e8a-9c7a-dd0fa3c17525
md"""
**Exercise**
Find the volume of the solid obtained by rotating the region bounded by ``y=x^3``, ``y=8`` , and ``x=0`` about the ``y``-axis.
"""

# ╔═╡ 635e4f34-9401-4234-936b-8b1029c6a7db
md"""
**Exercise** The region ``\mathcal{R}`` enclosed by the curves ``y=x`` and ``y=x^2`` is rotated about the ``x``-axis. Find the volume of the resulting solid.

"""

# ╔═╡ c9b6ee5f-be74-4067-8bff-8e408ddd0196
md"""
**Exercise** Find the volume of the solid obtained by rotating the region in the previous Example about the line ``y=2``.
"""

# ╔═╡ 48dcb862-d764-4421-851a-213c9d733b02
md"""
**Exercise** Find the volume of the solid obtained by rotating the region in the previous Example about the line ``x=-1``.
"""

# ╔═╡ 8d1a94f7-f6e6-4b95-a45e-03550125801e
md"""
**Example 6** Figure below shows a solid with a circular base of radius ``1``. Parallel cross-sections perpendicular to the base are equilateral triangles. Find the volume of the solid.
$(load(download("https://www.dropbox.com/s/bbxedang718jvvp/img4.png?dl=0")))
"""

# ╔═╡ 3d267c3e-4509-48d6-a094-39e15940fd6c
md"""
## Section 7.3
**Volume: The Shell Method**
> __Objectives__
> - Find the volume of a solid of revolution using the shell method.
> - Compare the uses of the disk method and the shell method.

**Problem**
Find the volume of the solid generated by rotating the region bounded by ``y=2x^2-x^3`` and ``y=0`` about the ``y-``axis.
"""

# ╔═╡ 21848166-fbf0-4e1d-8e90-e0060abcc170
begin
	show_graph_s = @bind show_graph CheckBox() 
	show_rect_s = @bind show_rect CheckBox() 
	show_labels_s = @bind show_labels CheckBox() 
	md"""
	Step 1: $show_graph_s
	Step 2: $show_rect_s
	Step 3: $show_labels_s
	"""
end

# ╔═╡ 088a349a-f632-45af-866f-6315ed1e47a5
begin
	
	f30(x)=2*x^2-x^3
	s3e0= PlotData(0:0.01:2,f30)
	s3e0p0 = plot(s3e0)
	annotate!(s3e0p0,[(1,1.2,L"y=2x^2-x^3")])
	recty=Shape([ (0.75,f30(0.75))
			, (1.75,f30(0.75))
			, (1.75,f30(0.75)+0.05)
			, (0.75,f30(0.75)+0.05)])
	ux, lx = Plots.unzip(Plots.partialcircle(0,π,100,-0.1))
	plot!(ux,lx .+ 1.15,c=:red)
	anns = [(0.65,f30(0.76),L"x_L=?",10),(1.88,f30(0.76),L"x_R=?",10)]
	s3e0p =	if show_labels 
		plot!(s3e0p0,recty,label=nothing)
		annotate!(anns)
	elseif show_rect
		plot!(s3e0p0,recty,label=nothing)
	elseif show_graph
		s3e0p0
		
	else
		""
	end
end

# ╔═╡ 90d1778a-61bf-46ee-a7cd-5fd1b5d5d980
cm"""
### The Shell Method
"""

# ╔═╡ 1dbbef99-3674-42fe-ab48-1ab6b72d0652
begin 
	shellImg=load(download("https://www.dropbox.com/s/8a2njc50e2hptok/shell.png?dl=0"))
	md"""
	A shell is a hallow circular cylinder
	
	$shellImg
	"""
end

# ╔═╡ 05af66f4-1013-4374-8c85-9265f123934e
md"""
```math
V = 2 \pi r h \Delta r = \text{[circumference][height][thickness]}

```
"""

# ╔═╡ 7396e0b3-753e-40fa-8bb5-30ccb4bac550
html"""
<div style="display: flex; justify-content:center; padding:20px; border: 2px solid rgba(125,125,125,0.2);">
<div>
<h5>Cylindrical Shells Illustration</h5>
<iframe width="560" height="315" src="https://www.youtube.com/embed/JrRniVSW9tg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>
</div>
"""

# ╔═╡ d3139bfe-4ae8-49d3-a9a5-19bd222a1eca
cm"""
<div style="display: flex;  justify-content: center;">
<div style="margin-right:12px;padding:4px;border: 2px solid white; border-radius: 10px;background: #eee;">
<span style="font-size:1.5M; font-weight: 800;">Horizontal Axis of Revolution</span>

```math
\text{Volume}=V = 2\pi \int_c^d p(y) h(y) dy
```
<div class="img-container">

$(Resource("https://www.dropbox.com/s/6qmijrhprht4kqj/shell_y.png?raw=1"))

</div>

</div>

<div style="margin-right:12px;padding:4px;border: 2px solid white; border-radius: 10px;background: #eee;"><span style="font-size:1.5M; font-weight: 800;">Vertical  Axis of Revolution</span>

```math
\text{Volume}=V = 2\pi \int_a^b p(x) h(x) dx
```

<div class="img-container">

$(Resource("https://www.dropbox.com/s/ivbwuge5ti8vrff/shell_x.png?raw=1"))

</div>

</div>
</div>

"""

# ╔═╡ 5e5c5013-2b13-4a59-a325-91ebcf811cb2
begin
	s3e0p1 = plot(s3e0)
	annotate!(s3e0p1,[(1,1.2,L"y=2x^2-x^3")])
	plot!(s3e0p1, 
			Shape( 
				[ (1.2,0),(1.3,0),(1.3,f30(1.3)),(1.2,f30(1.3))
				]
				)
		, label=nothing
		)
	md"""
**Example 1:**
Find the volume of the solid generated by rotating the region bounded by ``y=2x^2-x^3`` and ``y=0`` about the ``y-``axis.

Solution:
	
$s3e0p1
"""
end

# ╔═╡ d61e07a2-25da-4189-9689-57a6bb642b6e
md"""
**Example 2:**
Find the volume of the solid obtained by rotating about the ``y-``axis the region between ``y=x`` and ``y=x^2``.

"""

# ╔═╡ 5072c45e-2efd-44cf-a0fc-380972e270e2
md"""
**Example 4:**
Find the volume of the solid obtained by rotating the region bounded by ``y=x-x^2`` and ``y=0`` about the line ``x=2``.

"""

# ╔═╡ 28e60db5-e3d7-49d5-b530-97fc52a8fe5b
md"""
## Section 7.4 
**Arc Length and Surfaces of Revolution**
> __Objectives__
> - Find the arc length of a smooth curve.
> - Find the area of a surface of revolution.

"""

# ╔═╡ 74b15b63-ce1a-4d61-b000-9cd64a0fa8d1
cm"""
### Arc Length
"""

# ╔═╡ 530c6d53-1a7b-4b0f-87c3-949e92d16784
cm"""
__Definition of Arc Length__

Let the function ``y=f(x)`` represents a smooth curve on the interval ``[a,b]``. The __arc length__ of ``f`` between ``a`` and ``b`` is
```math
s = \int_a^b\sqrt{1+[f'(x)]^2} dx.
```

Similarly, for a smooth curve ``x=g(y)``, the arc length of ``g`` between ``c`` and  ``d`` is
```math
s = \int_c^d\sqrt{1+[g'(y)]^2} dy.
```

"""

# ╔═╡ b01b8817-be8d-4c67-8a8f-8515d11da0f5
cm"""
__Example__ 
Find the arc length of the graph of ``y=\displaystyle \frac{x^3}{6}+\frac{1}{2x}`` on the interval ``[\frac{1}{2},2]``. 
"""


# ╔═╡ 0a19d8c3-163a-42e8-9c4b-10dba2e7fe9e
cm"""
__Example__ Find the arc length of the graph of ``y=\ln(\cos x)`` from ``x=0`` to ``x=\pi/4``.
"""

# ╔═╡ 7c7ee2ba-39ed-4513-af13-aab5330bc1cd
cm"""
### Area of a Surface of Revolution
__Definition of Surface of Revolution__ When the graph of a continuous function is revolved about a line, the resulting surface is a __surface of revolution__.

<div class="img-container">

$(Resource("https://www.dropbox.com/s/199tfveph8mi2kz/surface_rev.png?raw=1"))

__Surface Area of *frustum*__
```math
S=2\pi r L, \quad \text{where}\quad r=\frac{r_1+r_2}{2}
```
</div>

Consider a function ``f`` that has a continuous derivative on the interval ``[a,b]``. The graph of ``f`` is revolved about the ``x``-axis

<div class="img-container">

$(Resource("https://www.dropbox.com/s/f454ldbfk1z3o2z/surface_rev2.png?raw=1"))

__Surface Area Formula__
```math
S=2\pi \int_a^b x \sqrt{1+[f'(x)]^2} dx.
```
</div>

__Definition of the Area of a Surface of Revolution__

Let ``y=f(x)`` have a continuous derivative on the interval ``[a,b]``. 

<div class="img-container">

$(Resource("https://www.dropbox.com/s/2fup4uwh5uclrmv/surface_rev3.png?raw=1"))
</div>

The area ``S`` of the surface of revolution formed by revolving the graph of ``f`` about a horizontal or vertical axis is

```math
S=2\pi \int_a^b r(x) \sqrt{1+[f'(x)]^2} dx, \quad {\color{red} y \text{ is a function of x }}.
```
where ``r(x)`` is the distance between the graph of ``f`` and the axis of revolution. 

If ``x=g(y)`` on the interval ``[c,d]`` , then the surface area is

```math
S=2\pi \int_a^b r(y) \sqrt{1+[g'(y)]^2} dy, \quad {\color{red} x \text{ is a function of y }}.
```
where ``r(y)`` is the distance between the graph of ``g`` and the axis of revolution.

"""

# ╔═╡ 0672c4e3-c42d-4c7c-ab75-0fd97d181469
cm"""
__Remark__ 

The formulas can be written as

```math
S=2\pi \int_a^b r(x) ds, \quad {\color{red} y \text{ is a function of x }}.
```
and 
```math
S=2\pi \int_c^d r(y) ds, \quad {\color{red} x \text{ is a function of y }}.
```
where 
```math
ds = \sqrt{1+\big[f'(x)\big]^2}dx \quad \text{and}\quad ds = \sqrt{1+\big[g'(y)\big]^2}dy \quad \text{respectively}.
"""

# ╔═╡ 543df37f-92fd-43a6-b864-9ed60e81eeda
cm"""
__Example__ Find the area of the surface formed by revolving the graph of ``f(x)=x^3`` on the interval ``[0,1]`` about the ``x``-axis.


__Example__ Find the area of the surface formed by revolving the graph of ``f(x)=x^2`` on the interval ``[0,\sqrt{2}]`` about the ``y``-axis.
"""

# ╔═╡ ca2016b0-83dd-445f-99a0-b685d6151eb3
hline()=html"<hr>"

# ╔═╡ ad3dd437-7cfc-4cdc-a951-15949d39cf15
rect(x,Δx,xs,f)=Shape([(x,0),(x+Δx,0),(x+Δx,f(xs)),(x,f(xs))])
#Shape(x .+ [0,Δx,Δx,0], [0,0,f(xs),f(xs)])

# ╔═╡ a9d0c669-f6d7-4e5f-8f57-b6bffe1710ba
function reimannSum(f,n,a,b;method="l",color=:green)
	Δx =(b-a)/n
	x =a:0.1:b
	# plot(f;xlim=(-2π,2π), xticks=(-2π:(π/2):2π,["$c π" for c in -2:0.5:2]))
	
	p=plot(x,f.(x);legend=nothing)
	(partition,recs) = if method=="r"
		 parts = (a+Δx):Δx:b
		 rcs = [rect(p-Δx,Δx,p,f) for p in parts]
		 (parts,rcs)
	elseif method=="m"
		parts = (a+(Δx/2)):Δx:(b-(Δx/2))
		rcs = [rect(p-Δx/2,Δx,p,f) for p in parts]
		(parts,rcs)
	elseif method=="l"
		parts = a:Δx:(b-Δx)
		rcs = [rect(p,Δx,p,f) for p in parts]
		(parts,rcs)
	else 
		parts = a:Δx:(b-Δx)
		rcs = [rect(p,Δx,rand(p:0.1:p+Δx),f) for p in parts]
		(parts,rcs)
	end
	# recs= [rect(sample(p,Δx),Δx,p,f) for p in partition]
	plot!(p,recs,framestyle=:origin,opacity=.4, color=color)
	s = round(sum(f.(partition)*Δx),sigdigits=6)
	return (p,s)
end

# ╔═╡ 6a5d1a86-4b9e-4d65-9bd7-f39ef8b6d9b4
StartPause() = @htl("""
<div>
<button>Start</button>

<script>

	// Select elements relative to `currentScript`
	var div = currentScript.parentElement
	var button = div.querySelector("button")

	// we wrapped the button in a `div` to hide its default behaviour from Pluto

	var count = false

	button.addEventListener("click", (e) => {
		count = !count

		// we dispatch the input event on the div, not the button, because 
		// Pluto's `@bind` mechanism listens for events on the **first element** in the
		// HTML output. In our case, that's the div.

		div.value = count
		div.dispatchEvent(new CustomEvent("input"))
		e.preventDefault()
		button.innerHTML = count? "Pause" : "Start"
	})
	// Set the initial value
	div.value = count

</script>
</div>
""")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CommonMark = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
Contour = "d38c429a-6771-53c6-b99e-75d170b6e991"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
ImageTransformations = "02fcd773-0e25-5acc-982a-7f6622650795"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
PlotThemes = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"

[compat]
CommonMark = "~0.8.6"
Contour = "~0.6.2"
FileIO = "~1.15.0"
HypertextLiteral = "~0.9.4"
ImageIO = "~0.6.6"
ImageShow = "~0.3.6"
ImageTransformations = "~0.9.5"
LaTeXStrings = "~1.3.0"
PlotThemes = "~3.0.0"
Plots = "~1.33.0"
PlutoUI = "~0.7.40"
SymPy = "~1.1.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0"
manifest_format = "2.0"
project_hash = "0b230138cd767b79e4485d940843a33a8f7c0a21"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dc4405cee4b2fe9e1108caec2d760b7ea758eca2"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.5"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonEq]]
git-tree-sha1 = "d1beba82ceee6dc0fce8cb6b80bf600bbde66381"
uuid = "3709ef60-1bee-4518-9f2f-acd86f176c50"
version = "0.2.0"

[[deps.CommonMark]]
deps = ["Crayons", "JSON", "URIs"]
git-tree-sha1 = "4cd7063c9bdebdbd55ede1af70f3c2f48fab4215"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "0.8.6"

[[deps.CommonSolve]]
git-tree-sha1 = "332a332c97c7071600984b3c31d9067e1a4e6e25"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.1"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "6e47d11ea2776bc5627421d59cdcc1296c058071"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.7.0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "94f5101b96d2d968ace56f7f2db19d0a5f592e28"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.15.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "cf0a9940f250dc3cb6cc6c6821b4bf8a4286cf9c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.66.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "3697c23d09d5ec6f2088faa68f0d926b6889b5be"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.67.0+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "59ba44e0aa49b87a8c7a8920ec76f8afe87ed502"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.3.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "b563cf9ae75a635592fc73d3eb78b86220e55bd8"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.6"

[[deps.ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "8717482f4a2108c9358e5c3ca903d3a6113badc9"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.5"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "f67b55b6447d36733596aea445a9f119e83498b6"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.5"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "6872f9594ff273da6d13c7c1a1545d5a8c7d0c1c"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.6"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "1ea784113a6aa054c5ebd95945fa5e52c2f378e7"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.7"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "e925a64b8585aa9f4e3047b8d2cdc3f0e79fd4e4"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.16"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6062b3b25ad3c58e817df0747fc51518b9110e5f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.33.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "a602d7b0babfca89005da04d89223b867b55319f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.40"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "53b8b07b721b77144a0fbbbc2675222ebf40a02d"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.94.1"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.Quaternions]]
deps = ["DualNumbers", "LinearAlgebra", "Random"]
git-tree-sha1 = "b327e4db3f2202a4efafe7569fcbe409106a1f75"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.5.6"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "e7eac76a958f8664f2718508435d058168c7953d"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "22c5201127d7b243b9ee1de3b43c408879dff60f"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.3.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "3d52be96f2ff8a4591a9e2440036d4339ac9a2f7"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.3.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "efa8acd030667776248eabb054b1836ac81d92f0"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.7"

[[deps.StaticArraysCore]]
git-tree-sha1 = "ec2bd695e905a3c755b33026954b119ea17f2d22"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.3.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.SymPy]]
deps = ["CommonEq", "CommonSolve", "Latexify", "LinearAlgebra", "Markdown", "PyCall", "RecipesBase", "SpecialFunctions"]
git-tree-sha1 = "de83b8c89b2744fee5279326fe8e3f4a9b94d1e1"
uuid = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
version = "1.1.7"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "70e6d2da9210371c927176cb7a56d41ef1260db7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─0c3da8f0-7138-4521-ac5b-362a36380a8c
# ╟─014747b8-d1be-414b-adcb-1bc6971b84be
# ╟─ad045108-9dca-4a61-ac88-80a3417c95f2
# ╟─1e9f4829-1f50-47ae-8745-0daa90e7aa42
# ╟─90f42d35-f81e-4c38-8a73-77b37755f671
# ╟─aac97852-3abc-4455-80fe-a61aec320d24
# ╟─e427ab16-9d5a-4200-8d96-8e49ec0da312
# ╟─2ddde4c4-8217-41e3-9235-a6370b11ae5c
# ╟─07dee140-2553-4b2e-bd28-1dda978fb34c
# ╟─d7928de3-89a4-4475-ba5b-2e707084685b
# ╟─784142ee-1416-4ccb-a341-0497422009b6
# ╟─a65d268a-cb45-4d6c-ac77-ac719010cfb3
# ╟─6a4dd437-8be1-4e17-b484-65707ec28215
# ╟─4337bc1f-933f-4e8d-abae-46b8ad99409e
# ╟─539cbac4-c1be-4f9d-b076-215c4430a3a6
# ╟─1006936d-e13e-4146-b0ac-905acb1f7d08
# ╟─64f36566-5747-4c8f-b90f-1ced674365cb
# ╟─61b6234e-5cb2-4337-ae29-14106ac6bd59
# ╠═237a0543-7d70-48ff-a8b5-37bb31dd98d8
# ╠═e370f794-41b6-4acf-9ef6-453fba223dea
# ╟─629f1cf7-ffa9-496b-9a3f-405089b43a8e
# ╟─0b4677a8-93e3-4fc9-91e8-8a7e77d18e2b
# ╟─598b7b2e-01dd-41aa-966a-a361921a5c60
# ╟─ffcdd27d-0974-4071-9543-8474a02f09e8
# ╟─e7a8a1e7-b4c5-4d33-8e2d-e4fd6b15e89b
# ╟─35c589c5-8206-4cd5-b4e6-cc5758d17cf6
# ╟─bc3988a9-048c-4bbf-8197-edcea8898818
# ╟─dad5ee5f-b2f4-4582-b2ef-855e7b9dc49b
# ╟─02fd559e-2a51-4a15-af4e-bd50149cb0e8
# ╟─5c1989f5-bd7b-4c82-a9e3-54f47539fe2d
# ╟─078023da-23bc-4401-a1dc-fe869400f9b0
# ╟─440eec5a-5a9b-4783-9dd2-3427fe340bc6
# ╟─835bf3cc-eca3-4e8a-9c7a-dd0fa3c17525
# ╟─635e4f34-9401-4234-936b-8b1029c6a7db
# ╟─c9b6ee5f-be74-4067-8bff-8e408ddd0196
# ╟─48dcb862-d764-4421-851a-213c9d733b02
# ╟─8d1a94f7-f6e6-4b95-a45e-03550125801e
# ╟─3d267c3e-4509-48d6-a094-39e15940fd6c
# ╟─21848166-fbf0-4e1d-8e90-e0060abcc170
# ╟─088a349a-f632-45af-866f-6315ed1e47a5
# ╟─90d1778a-61bf-46ee-a7cd-5fd1b5d5d980
# ╟─1dbbef99-3674-42fe-ab48-1ab6b72d0652
# ╟─05af66f4-1013-4374-8c85-9265f123934e
# ╟─7396e0b3-753e-40fa-8bb5-30ccb4bac550
# ╟─d3139bfe-4ae8-49d3-a9a5-19bd222a1eca
# ╟─5e5c5013-2b13-4a59-a325-91ebcf811cb2
# ╟─d61e07a2-25da-4189-9689-57a6bb642b6e
# ╟─5072c45e-2efd-44cf-a0fc-380972e270e2
# ╟─28e60db5-e3d7-49d5-b530-97fc52a8fe5b
# ╟─74b15b63-ce1a-4d61-b000-9cd64a0fa8d1
# ╟─530c6d53-1a7b-4b0f-87c3-949e92d16784
# ╟─b01b8817-be8d-4c67-8a8f-8515d11da0f5
# ╟─0a19d8c3-163a-42e8-9c4b-10dba2e7fe9e
# ╟─7c7ee2ba-39ed-4513-af13-aab5330bc1cd
# ╟─0672c4e3-c42d-4c7c-ab75-0fd97d181469
# ╟─543df37f-92fd-43a6-b864-9ed60e81eeda
# ╟─ca2016b0-83dd-445f-99a0-b685d6151eb3
# ╟─a9d0c669-f6d7-4e5f-8f57-b6bffe1710ba
# ╟─ad3dd437-7cfc-4cdc-a951-15949d39cf15
# ╟─6a5d1a86-4b9e-4d65-9bd7-f39ef8b6d9b4
# ╟─e93c5882-1ef8-43f6-b1ee-ee23c813c91b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
